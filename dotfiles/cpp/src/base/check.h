#ifndef SRC_CHECK_H_
#define SRC_CHECK_H_
#include <sstream>

class FatalMessageVoidify {
 public:
  FatalMessageVoidify() { }
  // This has to be an operator with a precedence lower than << but
  // higher than ?:
  template <typename T>
  void operator&(const T&) { }
};

class FatalMessage {
 public:
  FatalMessage(const char* file, int line, const char* func);
  ~FatalMessage();
  template <typename T>
  FatalMessage& operator<<(const T& t) {
    ss_ << t;
    return *this;
  }
 private:
  std::stringstream ss_;
};

// eg  CHECK(ptr) << "ptr is null";
#define CHECK(x) \
  (x) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__)

#define CHECK_EQ(x, y) \
  ((x) == (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " == " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_NE(x, y) \
  ((x) != (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " != " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_LT(x, y) \
  ((x) < (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " < " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_LE(x, y) \
  ((x) <= (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " <= " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_GT(x, y) \
  ((x) > (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " > " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_GE(x, y) \
  ((x) >= (y)) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " >= " #y ", " << (x) << " vs " << (y) << " "

#define CHECK_NOTNULL(x) \
  ((x) != nullptr) ? static_cast<void>(0) : FatalMessageVoidify() & FatalMessage(__FILE__, __LINE__, __FUNCTION__) \
  << "Check failed: " #x " != nullptr "



#ifdef NDEBUG
#define DCHECK(x) while (false) CHECK(x)
#define DCHECK_EQ(x, y) while (false) CHECK_EQ(x, y)
#define DCHECK_NE(x, y) while (false) CHECK_NE(x, y)
#define DCHECK_LT(x, y) while (false) CHECK_LT(x, y)
#define DCHECK_LE(x, y) while (false) CHECK_LE(x, y)
#define DCHECK_GT(x, y) while (false) CHECK_GT(x, y)
#define DCHECK_GE(x, y) while (false) CHECK_GE(x, y)
#define DCHECK_NOTNULL(x) while (false) CHECK_NOTNULL(x)
#else
#define DCHECK(x) CHECK(x)
#define DCHECK_EQ(x, y) CHECK_EQ(x, y)
#define DCHECK_NE(x, y) CHECK_NE(x, y)
#define DCHECK_LT(x, y) CHECK_LT(x, y)
#define DCHECK_LE(x, y) CHECK_LE(x, y)
#define DCHECK_GT(x, y) CHECK_GT(x, y)
#define DCHECK_GE(x, y) CHECK_GE(x, y)
#define DCHECK_NOTNULL(x) CHECK_NOTNULL(x)
#endif
#endif // SRC_CHECK_H
