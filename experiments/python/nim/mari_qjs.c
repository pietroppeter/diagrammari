/* diagrammari: a tiny C shim over QuickJS (quickjs-ng), so Nim sees four functions. */
#include <stdlib.h>
#include <string.h>
#include "quickjs.h"

typedef struct { JSRuntime *rt; JSContext *ctx; } MariJs;

static char *dup_str(JSContext *ctx, JSValueConst v) {
  size_t n; const char *s = JS_ToCStringLen(ctx, &n, v);
  if (!s) return NULL;
  char *out = malloc(n + 1); memcpy(out, s, n); out[n] = 0;
  JS_FreeCString(ctx, s); return out;
}

static char *exception_text(JSContext *ctx) {
  JSValue e = JS_GetException(ctx);
  char *s = dup_str(ctx, e); JS_FreeValue(ctx, e);
  return s ? s : strdup("unknown JavaScript error");
}

/* Evaluate `code` (a script) in a new context; *err gets a message on failure. */
void *mari_js_new(const char *code, size_t len, char **err) {
  MariJs *m = calloc(1, sizeof *m);
  m->rt = JS_NewRuntime(); m->ctx = JS_NewContext(m->rt);
  JS_SetMaxStackSize(m->rt, 8 * 1024 * 1024);
  JSValue r = JS_Eval(m->ctx, code, len, "<mari>", JS_EVAL_TYPE_GLOBAL);
  *err = NULL;
  if (JS_IsException(r)) *err = exception_text(m->ctx);
  JS_FreeValue(m->ctx, r);
  return m;
}

/* Call global function `fn` with one string argument; a malloc'd string back. */
char *mari_js_call(void *h, const char *fn, const char *arg, size_t len, int *ok) {
  MariJs *m = h; JSContext *ctx = m->ctx;
  JSValue g = JS_GetGlobalObject(ctx), f = JS_GetPropertyStr(ctx, g, fn);
  JSValue a = JS_NewStringLen(ctx, arg, len);
  JSValue r = JS_Call(ctx, f, g, 1, &a);
  char *out;
  if (JS_IsException(r)) { *ok = 0; out = exception_text(ctx); }
  else { *ok = 1; out = dup_str(ctx, r); }
  JS_FreeValue(ctx, r); JS_FreeValue(ctx, a); JS_FreeValue(ctx, f); JS_FreeValue(ctx, g);
  return out;
}

void mari_js_free_str(char *s) { free(s); }
void mari_js_close(void *h) { MariJs *m = h; JS_FreeContext(m->ctx); JS_FreeRuntime(m->rt); free(m); }
