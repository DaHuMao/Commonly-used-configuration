#ifndef CMD_COMPLETE_ZSH_MODULE_ZSH_COMPAT_H_
#define CMD_COMPLETE_ZSH_MODULE_ZSH_COMPAT_H_

// Minimal zsh 5.9 module ABI, matching Src/zsh.h and Src/module.c.
// These declarations remove the build dependency on generated zsh headers.
// The builtin layout and flag values must match the zsh loading this module.
// Options and Module are only passed through, so their layouts are not needed.
struct options;
struct module;
using Options = options *;
using Module = module *;
using HandlerFunc = int (*)(char *, char **, Options, int);

struct hashnode {
  hashnode *next;
  char *nam;
  int flags;
};

struct builtin {
  hashnode node;
  HandlerFunc handlerfunc;
  int minargs;
  int maxargs;
  int funcid;
  char *optstr;
  char *defopts;
};
using Builtin = builtin *;

constexpr int BINF_ADDED = 1 << 3;
constexpr int BINF_BUILTIN = 1 << 7;
constexpr int BINF_NOGLOB = 1 << 10;
constexpr int BINF_SKIPINVALID = 1 << 12;
constexpr int BINF_HANDLES_OPTS = 1 << 18;

// zsh's C interface uses char* for the descriptor strings. It replaces the
// name with an allocated copy when registering the builtin.
#define BUILTIN(name, flags, handler, min, max, funcid, optstr, defopts) \
  {{nullptr, const_cast<char *>(name), flags}, handler, min, max, funcid, \
   const_cast<char *>(optstr), defopts}

extern "C" {
int addbuiltins(const char *name, Builtin builtins, int count);
int deletebuiltin(const char *name);
}

#endif  // CMD_COMPLETE_ZSH_MODULE_ZSH_COMPAT_H_
