//
//  KBArray.mm
//  KBAPISupport
//
//  Created by Kirill Bystrov on 7/17/18.
//  Copyright © 2018 Kirill byss Bystrov. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#include "KBArray.h"

#import <typeinfo>
#import <objc/runtime.h>
#import <malloc/malloc.h>

@interface KBHeapArray: KBArray
@end
@interface KBInlineArray0: KBArray
@end
@interface KBInlineArray1: KBArray
@end
@interface KBInlineArray2: KBArray
@end
@interface KBInlineArray3: KBArray
@end
@interface KBInlineArray4: KBArray
@end

namespace KB {
	template <typename _Stor, size_t _Pad>
	class ArrayImpl {
	public:
		ArrayImpl (Class isa, NSUInteger const capacity): isa (isa), _storage (capacity) {}
		~ArrayImpl () = default;
		
		inline NSUInteger capacity () const {
			return this->_storage.capacity ();
		}
		
		inline NSUInteger count () const {
			return this->_storage.count ();
		}

		inline id objectAtIndex (NSUInteger const index) const {
			return this->_storage.objectAtIndex (index);
		}
		
		inline void appendObject (id const object) {
			if (object) {
				this->_storage.appendObject (object);
			}
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			if (count) {
				this->_storage.appendObjects (objects, count);
			}
		}

	private:
		Class const isa;
		_Stor _storage;
		void *_padding [_Pad];
	};
	
	template <typename _Stor>
	[[noreturn]] void capacityExceeded (_Stor const *const storage) {
		NSString *const reason = [NSString stringWithFormat:@"%s %p: capacity exceeded (%ld)", typeid (_Stor).name (), storage, (long) storage->capacity ()];
		@throw [[NSException alloc] initWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
	}
	
	template <typename _Stor>
	[[noreturn]] void indexOutOfBounds (_Stor const *const storage, NSUInteger const index) {
		NSString *const reason = [NSString stringWithFormat:@"%s %p: index %ld out of bounds (0 ..< %ld)", typeid (_Stor).name (), storage, (long) index, (long) storage->count ()];
		@throw [[NSException alloc] initWithName:NSInternalInconsistencyException reason:reason userInfo:nil];
	}

	struct ArrayStorage {
	public:
		struct Heap;
		template <NSUInteger N>
		struct Inline;

		inline NSUInteger count () const {
			return this->_count;
		}
		
	protected:
		inline void releaseObjects (id *objects) {
			for (id *const objectsEnd = objects + this->_count; objects < objectsEnd; [*objects++ release]);
		}
		
		inline void appendObjectsImpl (id *__restrict objects, id const *__restrict const appended, NSUInteger const count) {
			if (!count) {
				return;
			}
			memcpy (objects, appended, sizeof (id) * count);
			for (id *const objectsEnd = objects + count; objects < objectsEnd; [*objects++ retain]);
			this->_count += count;
		}
		
	private:
		NSUInteger _count;
	};
	
	struct ArrayStorage::Heap: public ArrayStorage {
	public:
		Heap (NSUInteger const capacity): _capacity (malloc_good_size (capacity / sizeof (id)) * sizeof (id)), _objects ((id *) calloc (_capacity, sizeof (id))) {}
		~Heap () {
			if (this->_objects) {
				this->releaseObjects (this->_objects);
				free (this->_objects);
			}
		}
		
		inline NSUInteger capacity () const {
			return this->_capacity;
		}
		
		inline void appendObject (id const object) {
			if (this->_capacity > this->_count) {
				this->_objects [this->_count++] = [object retain];
			} else {
				capacityExceeded (this);
			}
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			if (this->_capacity < this->_count + count) {
				capacityExceeded (this);
			}
			this->appendObjectsImpl (this->_objects, objects, count);
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			if (index < this->_count) {
				return this->_objects [index];
			}
			indexOutOfBounds (this, index);
		}

	private:
		NSUInteger _capacity;
		id *_objects;
	};
	
	template <NSUInteger N>
	struct ArrayStorage::Inline: public ArrayStorage {
	public:
		__attribute__((diagnose_if (capacity > N, "Invalid capacity", "error")))
		Inline (NSUInteger const capacity) {
			_objects [N - 1] = nil;
		}
		~Inline () {
			this->releaseObjects (this->_objects);
		}

		inline NSUInteger capacity () const {
			return N;
		}
		
		inline void appendObject (id const object) {
			if (this->_objects [N - 1]) {
				capacityExceeded (this);
			}
			this->_objects [this->_count++] = [object retain];
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			if (N < this->_count + count) {
				capacityExceeded (this);
			}
			this->appendObjectsImpl (this->_objects, objects, count);
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			if (index < this->_count) {
				return this->_objects [index];
			}
			indexOutOfBounds (this, index);
		}

	private:
		id _objects [N];
	};
	
	template<>
	struct ArrayStorage::Inline <0> {
	public:
		__attribute__((diagnose_if (capacity, "Invalid capacity", "error")))
		Inline (NSUInteger const capacity) {}
		~Inline () = default;
		
		inline NSUInteger capacity () const {
			return 0;
		}
		
		inline NSUInteger count () const {
			return 0;
		}
		
		inline void appendObject (id const object) {
			capacityExceeded (this);
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			capacityExceeded (this);
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			indexOutOfBounds (this, index);
		}
	};

	template<>
	struct ArrayStorage::Inline <1> {
	public:
		__attribute__((diagnose_if (capacity > 1, "Invalid capacity", "error")))
		Inline (NSUInteger const capacity): _object (nil) {}
		~Inline () {
			[_object release];
		}

		inline NSUInteger capacity () const {
			return 1;
		}
		
		inline NSUInteger count () const {
			return this->_object ? 1 : 0;
		}
		
		inline void appendObject (id const object) {
			if (this->_object) {
				capacityExceeded (this);
			}
			this->_object = [object retain];
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			if (this->_object || (count > 1)) {
				capacityExceeded (this);
			}
			this->_object = [*objects retain];
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			if (index) {
				indexOutOfBounds (this, index);
			}
			return this->_object;
		}

	private:
		id _object;
	};
	
	template<>
	class ArrayStorage::Inline <2> {
	public:
		__attribute__((diagnose_if (capacity > 2, "Invalid capacity", "error")))
		Inline (NSUInteger const capacity): _firstObject (nil), _lastObject (nil) {}
		~Inline () {
			[_firstObject release];
			[_lastObject release];
		}

		inline NSUInteger capacity () const {
			return 2;
		}
		
		inline NSUInteger count () const {
			return ((this->_firstObject ? 1 : 0) + (this->_lastObject ? 1 : 0));
		}
		
		inline void appendObject (id const object) {
			if (this->_lastObject) {
				capacityExceeded (this);
			}
			(this->_firstObject ? this->_lastObject : this->_firstObject) = [object retain];
		}
		
		inline void appendObjects (id *const objects, NSUInteger const count) {
			if (this->_lastObject) {
				capacityExceeded (this);
			}
			if (this->_firstObject) {
				if (count > 1) {
					capacityExceeded (this);
				}
				this->_lastObject = [*objects retain];
			} else {
				switch (count) {
					case 2:
						this->_lastObject = [*(objects + 1) retain];
						// fallthrough;
					case 1:
						this->_firstObject = [*objects retain];
						break;
					default:
						capacityExceeded (this);
				}
			}
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			switch (index) {
				case 0:
					return this->_firstObject;
				case 1:
					return this->_lastObject;
				default:
					indexOutOfBounds (this, index);
			}
		}

	private:
		id _firstObject;
		id _lastObject;
	};

	
	template<>
	class ArrayStorage::Inline <3> {
	public:
		__attribute__((diagnose_if (capacity > 3, "Invalid capacity", "error")))
		Inline (NSUInteger const capacity): _objects { nil, nil, nil } {}
		~Inline () {
			[this->_objects [0] release];
			[this->_objects [1] release];
			[this->_objects [2] release];
		}
		
		inline NSUInteger capacity () const {
			return 3;
		}
		
		inline NSUInteger count () const {
			if (this->_objects [1]) {
				if (this->_objects [2]) {
					return 3;
				} else {
					return 2;
				}
			} else {
				if (this->_objects [0]) {
					return 1;
				} else {
					return 0;
				}
			}
		}
		
		inline void appendObject (id const object) {
			if (this->_objects [1]) {
				if (this->_objects [2]) {
					capacityExceeded (this);
				}
				this->_objects [2] = [object retain];
			} else {
				this->_objects [this->_objects [0] ? 1 : 0] = [object retain];
			}
		}
		
		inline void appendObjects (id *objects, NSUInteger const count) {
			if (this->_objects [1]) {
				if (this->_objects [2] || (count > 1)) {
					capacityExceeded (this);
				} else {
					this->_objects [2] = [*objects retain];
				}
			} else {
				id *targetPtr = this->_objects + (this->_objects [0] ? 1 : 0);
				switch (count) {
					case 3:
						if (targetPtr > this->_objects) {
							capacityExceeded (this);
						}
						*targetPtr++ = [*objects++ retain];
						// fallthrough
					case 2:
						*targetPtr++ = [*objects++ retain];
						// fallthrough
					case 1:
						*targetPtr++ = [*objects++ retain];
						break;
					default:
						capacityExceeded (this);
				}
			}
		}
		
		inline id objectAtIndex (NSUInteger const index) const {
			if (index < 3) {
				id const result = this->_objects [index];
				if (result) {
					return result;
				}
			}
			indexOutOfBounds (this, index);
		}

	private:
		id _objects [3];
	};

	template <NSUInteger N>
	size_t const arrayImplPadding = 0;
	
#if __LP64__
	template <>
	size_t const arrayImplPadding <2> = 1;
#else
	template <>
	size_t const arrayImplPadding <0> = 2;
	template <>
	size_t const arrayImplPadding <1> = 2;
	template <>
	size_t const arrayImplPadding <2> = 1;
	template <>
	size_t const arrayImplPadding <4> = 2;
#endif
	
	NSUInteger const arrayImplHeapMin = 5;
	
	template <NSUInteger N>
	using arrayImplStorage = std::conditional_t <N < arrayImplHeapMin, ArrayStorage::Inline <N>, ArrayStorage::Heap>;
	
	template <NSUInteger N>
	using Array = ArrayImpl <arrayImplStorage <N>, arrayImplPadding <N>>;
	
	struct ObjC {
	private:
		struct ClassFactoryBase {
		protected:
			template <typename _Ar>
			static inline Class makeClass (char const *const className) {
				Class result = objc_allocateClassPair (publicClass, className, 0);
				class_addMethod (result, @selector (count), (IMP) objc_bridgeCount <_Ar>, (char []) { _C_LNG, _C_ID, _C_SEL, 0 });
				class_addMethod (result, @selector (appendObject:), (IMP) objc_bridgeAppendObject <_Ar>, (char []) { _C_VOID, _C_ID, _C_SEL, _C_ID, 0 });
				class_addMethod (result, @selector (appendObjects:count:), (IMP) objc_bridgeAppendObjects <_Ar>, (char []) { _C_VOID, _C_ID, _C_SEL, _C_ID, _C_LNG, 0 });
				class_addMethod (result, @selector (objectAtIndex:), (IMP) objc_bridgeObjectAtIndex <_Ar>, (char []) { _C_ID, _C_ID, _C_SEL, _C_LNG, 0 });
				class_addMethod (result, @selector (dealloc), (IMP) objc_bridgeDealloc <_Ar>, (char []) { _C_VOID, _C_ID, _C_SEL, 0 });
				objc_registerClassPair (result);
				return result;
			}
			
		private:
			static Class const publicClass;
			
			template <typename _Ar>
			static NSUInteger objc_bridgeCount (_Ar const *const array, SEL const selector) {
				return array->count ();
			}
			
			template <typename _Ar>
			static void objc_bridgeAppendObject (_Ar *const array, SEL const selector, id object) {
				return array->appendObject (object);
			}
			
			template <typename _Ar>
			static void objc_bridgeAppendObjects (_Ar *const array, SEL const selector, id *objects, NSUInteger count) {
				return array->appendObjects (objects, count);
			}
			
			template <typename _Ar>
			static id objc_bridgeObjectAtIndex (_Ar const *const array, SEL const selector, NSUInteger index) {
				return array->objectAtIndex (index);
			}
			
			template <typename _Ar>
			static void objc_bridgeDealloc (_Ar const *const array, SEL const selector) {
				delete array;
			}
		};
		
		template <NSUInteger N, typename _Stor>
		struct ClassFactory {};
		
		template <NSUInteger N>
		struct ClassFactory <N, ArrayStorage::Inline <N>>: public ClassFactoryBase {
		public:
			Class operator () () {
				static Class const result = makeClass ();
				return result;
			}
			
		private:
			static Class makeClass () {
				static_assert (N < 10, "Too long resulting class name");
				static char const className [] = { '$', 'K', 'B', 'I', 'n', 'l', 'i', 'n', 'e', 'A', 'r', 'r', 'a', 'y', N + '0', 0 };
				return ClassFactoryBase::makeClass <Array <N>> (className);
			}
		};
		
		template <NSUInteger N>
		struct ClassFactory <N, ArrayStorage::Heap>: public ClassFactoryBase {
		public:
			Class operator () () {
				static Class const result = makeClass ();
				return result;
			}
			
		private:
			static Class makeClass () {
				static_assert (N - arrayImplHeapMin < 10, "Too long resulting class name");
				static char const className [] = { '$', 'K', 'B', 'H', 'e', 'a', 'p', 'A', 'r', 'r', 'a', 'y', N - arrayImplHeapMin + '0', 0 };
				return ClassFactoryBase::makeClass <Array <N>> (className);
			}
		};
		
		template <NSUInteger N>
		static inline Array <N> *makeArray (NSUInteger const capacity) {
			return new Array <N> (ClassFactory <N, arrayImplStorage <N>> () (), capacity);
		}
		
	public:
		static inline KBArray *makeArray (NSUInteger const capacity) {
			switch (capacity) {
				case 0:
					return (KBArray *) ObjC::makeArray <0> (capacity);
				case 1:
					return (KBArray *) ObjC::makeArray <1> (capacity);
				case 2:
					return (KBArray *) ObjC::makeArray <2> (capacity);
				case 3:
					return (KBArray *) ObjC::makeArray <3> (capacity);
				case 4:
					return (KBArray *) ObjC::makeArray <4> (capacity);
				default:
					return (KBArray *) ObjC::makeArray <arrayImplHeapMin> (capacity);
			}
		}

	private:
		ObjC ();
		ObjC &operator= (ObjC const &);
	};

	namespace Diagnostics {
		template <NSUInteger N>
#if __LP64__
		NSUInteger const expectedArraySize = 32;
#else
		NSUInteger const expectedArraySize = 16;
#endif
		
#if __LP64__
		template <>
		NSUInteger const expectedArraySize <0> = 16;
		template <>
		NSUInteger const expectedArraySize <1> = 16;
		template <>
		NSUInteger const expectedArraySize <4> = 48;
#else
		template <>
		NSUInteger const expectedArraySize <4> = 32;
#endif
		
		template <NSUInteger N>
		__attribute__((diagnose_if(sizeof (Array <N>) != expectedArraySize <N>, "Possibly invalid array size", "warning")))
		__attribute__((always_inline))
		inline void checkArraySize () {
			if (malloc_good_size (sizeof (Array <N>)) != sizeof (Array <N>)) {
				NSLog (@"[KBAPISupport] Warning: sizeof (%s) is not \"malloc good\"", typeid (Array <N>).name ());
			}
		}
	};
}

@implementation KBArray

+ (void) load {
	KB::Diagnostics::checkArraySize <0> ();
	KB::Diagnostics::checkArraySize <1> ();
	KB::Diagnostics::checkArraySize <2> ();
	KB::Diagnostics::checkArraySize <3> ();
	KB::Diagnostics::checkArraySize <4> ();
	KB::Diagnostics::checkArraySize <8> ();
	KB::Diagnostics::checkArraySize <64> ();
	KB::Diagnostics::checkArraySize <512> ();
}

+ (instancetype) emptyArrayWithCapacity: (NSUInteger) capacity {
	return KB::ObjC::makeArray (capacity);
}

+ (instancetype) allocWithZone: (NSZone *) zone {
	return nil;
}

@end

Class const KB::ObjC::ClassFactoryBase::publicClass = [KBArray class];
