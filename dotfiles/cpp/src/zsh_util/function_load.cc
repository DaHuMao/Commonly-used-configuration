#include "zsh_util/function_load.h"

#include <cstring>
#include <dlfcn.h>
#include <mutex>

#include "base/log.h"
namespace zsh_util {
#define Meta		((char) 0x83)
#define META_STATIC     2
char *my_unmetafy(char *s, int *len) {
  char *p, *t;

  for (p = s; *p && *p != Meta; p++)
    ;
  for (t = p; (*t = *p++);)
    if (*t++ == Meta && *p)
      t[-1] = *p^ 32;
  if (len)
    *len = t - s;
  return s;
}

typedef void (*setsparam_func_t)(char *, char *);
typedef char *(*ztrdup_func_t)(const char *);
typedef char *(*unmetafy_func_t)(char *, int *);
typedef char *(*metafy_func_t)(char *, int, int);

static unmetafy_func_t unmetafy_ptr = nullptr;
static metafy_func_t metafy_ptr = nullptr;
static setsparam_func_t setsparam_ptr = nullptr;
static ztrdup_func_t ztrdup_ptr = nullptr;
static void *handle = nullptr;
static std::mutex init_mutex;
static bool initialized = false;

void InitFunctionLoad() {
  std::lock_guard<std::mutex> lock(init_mutex);
  if (initialized) {
    return;
  }
  initialized = true;
  // 尝试动态加载 zsh 的 unmetafy 符号
  handle = dlopen(NULL, RTLD_LAZY);  // 在当前进程中查找符号
  if (handle == nullptr) {
    LOG_E("zsh_util") << "Failed to open handle for symbol loading: "
                      << dlerror();
    return;
  }
  unmetafy_func_t system_unmetafy = (unmetafy_func_t)dlsym(handle, "unmetafy");
  if (system_unmetafy) {
    unmetafy_ptr = system_unmetafy;
    LOG_I("zsh_util") << "Successfully loaded system unmetafy function";
  } else {
    unmetafy_ptr = my_unmetafy;
    LOG_W("zsh_util") << "Failed to load unmetafy symbol: " << dlerror()
                      << ", using fallback my_unmetafy";
  }

  // 尝试动态加载 zsh 的 metafy 符号
  metafy_func_t system_metafy = (metafy_func_t)dlsym(handle, "metafy");
  if (system_metafy) {
    metafy_ptr = system_metafy;
    LOG_I("zsh_util") << "Successfully loaded system metafy function";
  } else {
    LOG_W("zsh_util") << "Failed to load metafy symbol: " << dlerror()
                      << ", using fallback my_metafy";
  }

  // 尝试动态加载 zsh 的 setsparam 符号
  setsparam_ptr = (setsparam_func_t)dlsym(handle, "setsparam");
  if (setsparam_ptr) {
    LOG_I("zsh_util") << "Successfully loaded system setsparam function";
  } else {
    LOG_E("zsh_util") << "Failed to load setsparam symbol: " << dlerror();
  }

  // 尝试动态加载 zsh 的 ztrdup 符号
  ztrdup_ptr = (ztrdup_func_t)dlsym(handle, "ztrdup");
  if (ztrdup_ptr) {
    LOG_I("zsh_util") << "Successfully loaded system ztrdup function";
  } else {
    LOG_E("zsh_util") << "Failed to load ztrdup symbol: " << dlerror();
  }
}

ztrdup_func_t GetZtrdupFuncPtr() { return ztrdup_ptr; }

char* UnMetafy(char *value, int *len) {
  if (unmetafy_ptr) {
    return unmetafy_ptr(value, len);
  } else {
    return my_unmetafy(value, len);
  }
}

char* Metafy(char *value, int len) {
  if (metafy_ptr) {
    return metafy_ptr(value, len, META_STATIC);
  }
  return nullptr;
}

void SetParamPtr(const char *name, const char *value) {
  if (setsparam_ptr) {
    setsparam_ptr((char*)name, ztrdup_ptr(value));
  }
}
}  // namespace zsh_util
