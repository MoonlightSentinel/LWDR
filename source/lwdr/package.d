module lwdr;

public import lwdr.tracking;

/// A static class by which to interface with core features of LWDR.
static final class LWDR
{
	/+/// Finalise and deallocate object `obj`
	static void free(ref Object obj) nothrow @nogc
	{
		import lifetime.class_;
		_d_delclass(&obj);
		obj = null;
	}+/
	
	static void free(T)(ref T obj) nothrow @nogc
		if(is(T == class) || is(T == interface))
	{
		import lifetime.class_;
		Object o = cast(Object)obj;
		_d_delclass(&o);
		obj = null;
	}

	version(LWDR_DynamicArray)
	/// Finalise (if possible) and deallocate dynamic array `arr`
	static void free(TArr : T[], T)(ref TArr arr)
	{
		import lifetime.array_;
		_d_delarray_t(cast(void[]*)&arr, typeid(T));
		arr = null;
	}

	/// Deallocate `ptr`
	static void free(TPtr : T*, T)(ref TPtr ptr) 
		if(!is(T == struct))
	{
		import lifetime.common;
		_d_delmemory(cast(void**)&ptr);
		ptr = null;
	}

	/// Finalise (if possible) and deallocate struct pointed to by `ptr`.
	static void free(TPtr : T*, T)(ref TPtr ptr) 
		if(is(T == struct))
	{
		import lifetime.common;
		TypeInfo_Struct s = cast(TypeInfo_Struct)typeid(T);
		s.dtor(ptr);
		_d_delmemory(cast(void**)&ptr);
		ptr = null;
	}

	version(LWDR_ManualDelegate)
	{
		/++
		Deallocate the context for a delegate. If the pointer isn't valid,
		then no action is taken. Hence, it is safe to call this for all types
		of delegate context types.
		++/
		static void freeDelegateContext(void* contextPtr)
		{
			import lifetime.delegate_;
			freeDelegate(contextPtr);
		}
	}

	version(LWDR_TLS)
	{
		/++ Register the current thread with LWDR.
		 + This will perform the necessary TLS allocations for this thread. ++/
		static void registerCurrentThread() nothrow @nogc
		{
			import rt.sections;
			initTLSRanges();
		}

		/++ Deregister the current thread from LWDR.
		 + If this thread was not registered, it will cause unknown behaviour.
		 + This will deallocate TLS memory for this thread. ++/
		static void deregisterCurrentThread() nothrow @nogc
		{
			import rt.sections;
			freeTLSRanges();
		}
	}
}