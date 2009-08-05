#include "nanojit.h"

#undef ST
#undef PUSHi

#ifdef __cplusplus
extern "C" {
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "ppport.h"

#include <stdint.h>

#include <ffi/ffi.h>

#ifdef __cplusplus
}
#endif

struct JIT_Function {
	nanojit::Fragment *f;
	unsigned args;
	ffi_cif cif;
};

typedef struct JIT_Function JIT_Function;
typedef JIT_Function * Devel__NanoJIT__Function;


#define OUTP_CLASS(cls) const char *CLASS = cls;

int nanojit::StackFilter::getTop(LInsp guard) {
	return 0;
}

void nanojit::Fragment::onDestroy() {
}

using namespace nanojit;

struct PLSideExit : public SideExit {
};

const uint32_t CACHE_SIZE_LOG2 = 20;  

static avmplus::GC *gGC;
static avmplus::AvmCore core;

ffi_type *sig_to_ffi_type(char s) {
	ffi_type *r = &ffi_type_void;
	switch(s) {
		case 'v': 	r = &ffi_type_void; 	break;
#ifdef USE_64_BIT_INT
		case 'I':	r = &ffi_type_uint64;	break;
		case 'i':	r = &ffi_type_sint64;	break;
#else
		case 'I':	r = &ffi_type_uint32;	break;
		case 'i':	r = &ffi_type_sint32;	break;
#endif
		case 'd':	r = &ffi_type_double;	break;

		default:	
			croak("Signature error: Unknown type '%c'", s);
	} 
	
	return r;
};

MODULE = Devel::NanoJIT		PACKAGE = Devel::NanoJIT::Function

IV
call(self, ...)
	Devel::NanoJIT::Function self;
	PREINIT:
		SV *rv;
		void **arg_values = NULL;
		ffi_arg result;
	CODE:
		if (self->args) {
			Newz(1, arg_values, self->args, void *);
			for (unsigned i = 0; i < self->args; i++) {
			}
		}
		ffi_call(&(self->cif), FFI_FN(self->f->code()), &result, arg_values);
		fprintf(stderr, "Return is: %d", (unsigned int) result);
		if (arg_values != NULL) {
			Safefree(arg_values);
		}
	OUTPUT:
		RETVAL

MODULE = Devel::NanoJIT		PACKAGE = Devel::NanoJIT::LirBufWriter

LirBufWriter *
new(CLASS, lirbuf)
	const char *CLASS;
	LirBuffer *lirbuf;
	PREINIT:
		LirBufWriter *w;
	CODE:
		w = new (gGC) LirBufWriter(lirbuf);
		RETVAL = w;
	OUTPUT:
		RETVAL
	
LIns *
insLoad(self, op, base, off)
	LirBufWriter *self;
	LOpcode op;
	LIns *base;
	LIns *off;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insLoad(op, base, off);
	OUTPUT:
		RETVAL

LIns *
insStore(self, o1, o2, o3)
	LirBufWriter *self;
	LIns *o1;
	LIns *o2;
	LIns *o3;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insStore(o1, o2, o3);
	OUTPUT:
		RETVAL

LIns *
insStorei(self, o1, o2, imm)
	LirBufWriter *self;
	LIns *o1;
	LIns *o2;
	int32_t imm;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insStorei(o1, o2, imm);
	OUTPUT:
		RETVAL
	
LIns *
ins0(self, opcode)
	LirBufWriter *self;
	LOpcode opcode;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->ins0(opcode);
	OUTPUT:
		RETVAL

LIns *
ins1(self, opcode, op1)
	LirBufWriter *self;
	LOpcode opcode;
	LIns *op1;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->ins1(opcode, op1);
	OUTPUT:
		RETVAL
		
LIns *
ins2(self, opcode, op1, op2)
	LirBufWriter *self;
	LOpcode opcode;
	LIns *op1;
	LIns *op2;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->ins2(opcode, op1, op2);
	OUTPUT:
		RETVAL

LIns *
insParam(self, i, kind)
	LirBufWriter *self;
	int32_t i;
	int32_t kind;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insParam(i, kind);
	OUTPUT:
		RETVAL

LIns *
insImm(self, imm)
	LirBufWriter *self;
	int32_t imm;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insImm(imm);
	OUTPUT:
		RETVAL

LIns *
insImmq(self, imm)
	LirBufWriter *self;
	uint64_t imm;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insImmq(imm);
	OUTPUT:
		RETVAL

LIns *
insGuard(self, op, cond, x)
	LirBufWriter *self;
	LOpcode op;
	LIns *cond;
	LIns *x;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insGuard(op, cond, x);
	OUTPUT:
		RETVAL

LIns *
insBranch(self, op, cond, to)
	LirBufWriter *self;
	LOpcode op;
	LIns *cond;
	LIns *to;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insBranch(op, cond, to);
	OUTPUT:
		RETVAL

LIns *
insAlloc(self, size)
	LirBufWriter *self;
	int32_t size;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LIns");
	CODE:
		RETVAL = self->insAlloc(size);
	OUTPUT:
		RETVAL

MODULE = Devel::NanoJIT		PACKAGE = Devel::NanoJIT::Fragment
		
Fragment *
new(CLASS)
	const char *CLASS;
	PREINIT:
		Fragment *f;
	CODE:
		f = new (gGC) Fragment(NULL);
		RETVAL = f;
	OUTPUT:
		RETVAL

LirBuffer *
lirbuf(self)
	Fragment *self;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::LirBuffer");
	CODE:
		RETVAL = self->lirbuf;
	OUTPUT:
		RETVAL
		
void
set_lirbuf(self, lirbuf)
	Fragment *self;
	LirBuffer *lirbuf;
	CODE:
		self->lirbuf = lirbuf;

Fragment *
root(self)
	Fragment *self;
	PREINIT:
		OUTP_CLASS("Devel::NanoJIT::Fragment");
	CODE:
		RETVAL = self->root;
	OUTPUT:
		RETVAL
		
void
set_root(self, root)
	Fragment *self;
	Fragment *root;
	CODE:
		self->root = root;
	
MODULE = Devel::NanoJIT		PACKAGE = Devel::NanoJIT::LirBuffer

LirBuffer *
new(CLASS, fragmento)
	const char *CLASS;
	Fragmento *fragmento;
	PREINIT:
		LirBuffer *lb;
	CODE:
		lb = new (gGC) LirBuffer(fragmento, NULL);
		RETVAL = lb;
	OUTPUT:
		RETVAL

MODULE = Devel::NanoJIT		PACKAGE = Devel::NanoJIT::Fragmento

Fragmento *
new(CLASS, cache_size_log2=CACHE_SIZE_LOG2)
	const char *CLASS;
	size_t cache_size_log2;
	PREINIT:
		Fragmento *f;
	CODE:
		f = new (gGC) Fragmento(&core, cache_size_log2);
		RETVAL = f;
	OUTPUT:
		RETVAL

MODULE = Devel::NanoJIT 	PACKAGE = Devel::NanoJIT

Devel::NanoJIT::Function
compile(fragmento, fragment, buf, signature)
	Fragmento *fragmento;
	Fragment *fragment;
	LirBufWriter *buf;
	const char *signature;
	PREINIT:
		LIns *skip;
		GuardRecord *guard;
		PLSideExit *xit;
		JIT_Function *f;
	CODE:
		if (signature == NULL) {
			croak("Invalid signature: %s", signature);
		}
		else if (strlen(signature) < 2) {
			croak("Invalid signature: %s", signature);
		}
		if (fragment->lastIns == NULL) {
			ffi_type **arg_types = NULL;
			ffi_type *ret_type;
			unsigned i = 0;
			const char *sig_ptr = signature;
			int args = strlen(signature) - 2;
			if (args > 0) {
				Newz(1, arg_types, args, ffi_type*);
				while(--args > 0) {
					arg_types[i++] = sig_to_ffi_type(*sig_ptr);
					sig_ptr++;
				}
			}
			if (*sig_ptr != ';') {
				croak("Invalid signature: expected ';' but got '%c'", *sig_ptr);
			}
			sig_ptr++;
			
			ret_type = sig_to_ffi_type(*sig_ptr);
			Newz(1, f, 1, JIT_Function);
			
			skip = buf->skip(sizeof(GuardRecord) + sizeof(PLSideExit));
    		guard = (GuardRecord *) skip->payload();
    		memset(guard, 0, sizeof(*guard));
			xit = (PLSideExit *) (guard + 1);
        	guard->exit = xit;
        	guard->exit->target = fragment;
    		fragment->lastIns = buf->insGuard(LIR_loop, buf->insImm(1), skip);

			compile(fragmento->assm(), fragment);
			if (fragmento->assm()->error() != None) {
				croak("Failed to compile fragment");
			}
			f->args = strlen(signature) - 2;
			if (ffi_prep_cif(&(f->cif), FFI_DEFAULT_ABI, f->args, ret_type, arg_types) != FFI_OK) {
				croak("Failed to define FFI interface to compiled function");
			}
			f->f = fragment;
			Safefree(arg_types);
		}
		else {
			warn("Fragment already compiled");
			XSRETURN_UNDEF;
		}
	OUTPUT:
		RETVAL

BOOT:
	core = avmplus::AvmCore();
	core.config.verbose = 1;