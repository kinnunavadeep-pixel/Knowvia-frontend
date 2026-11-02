# NPTEL Programming in Modern C++ — 4-Hour Code Pack

Each numbered example is an independent program. Copy one program at a time into a C++17 compiler. Learn in the order shown. The output below is the expected output.

## 1. Input, output, variable, and `if`

```cpp
#include <iostream>
using namespace std;

int main() {
    int mark = 75;
    cout << "Mark: " << mark << '\n';
    if (mark >= 50) cout << "Pass\n";
}
```

**Output**
```
Mark: 75
Pass
```

`int` stores an integer. `cout` prints. `if` runs its body only when its condition is true.

## 2. Loops

```cpp
#include <iostream>
using namespace std;

int main() {
    int sum = 0;
    for (int i = 1; i <= 4; ++i) sum += i;
    cout << sum << '\n';
}
```

**Output**
```
10
```

A `for` loop has initialization, condition, and update. Here it adds `1 + 2 + 3 + 4`.

## 3. Array and index

```cpp
#include <iostream>
using namespace std;

int main() {
    int a[3] = {10, 20, 30};
    cout << a[0] << ' ' << a[2] << '\n';
}
```

**Output**
```
10 30
```

An array has fixed size. Its first index is `0`; its last valid index here is `2`.

## 4. `string`

```cpp
#include <iostream>
#include <string>
using namespace std;

int main() {
    string name = "NPTEL";
    name += " C++";
    cout << name << " has " << name.size() << " characters\n";
}
```

**Output**
```
NPTEL C++ has 9 characters
```

`std::string` is a resizable sequence of characters. `+=` appends text and `size()` gives its length.

## 5. Sorting and binary search

```cpp
#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

int main() {
    vector<int> v = {8, 2, 5, 1};
    sort(v.begin(), v.end());
    cout << binary_search(v.begin(), v.end(), 5) << '\n';
}
```

**Output**
```
1
```

`sort` arranges values in ascending order. `binary_search` works on sorted data and returns `1` for found, `0` for not found.

## 6. Stack and queue

```cpp
#include <iostream>
#include <queue>
#include <stack>
using namespace std;

int main() {
    stack<int> st; st.push(10); st.push(20);
    queue<int> q; q.push(10); q.push(20);
    cout << st.top() << ' ' << q.front() << '\n';
}
```

**Output**
```
20 10
```

A stack is LIFO: last-in, first-out. A queue is FIFO: first-in, first-out.

## 7. Preprocessor, constant, and inline function

```cpp
#include <iostream>
#define BONUS 5
using namespace std;

inline int square(int n) { return n * n; }

int main() {
    const int mark = 4;
    cout << square(mark) + BONUS << '\n';
}
```

**Output**
```
21
```

`#define` is handled by the preprocessor before compilation. `const` cannot be changed. An `inline` function is a small function the compiler may expand at the call site.

## 8. Reference

```cpp
#include <iostream>
using namespace std;

int main() {
    int x = 10;
    int& ref = x;
    ref = 25;
    cout << x << '\n';
}
```

**Output**
```
25
```

A reference is another name for an existing variable. Changing `ref` changes `x`.

## 9. Pointer and dynamic memory

```cpp
#include <iostream>
using namespace std;

int main() {
    int* p = new int(10);
    *p = *p + 5;
    cout << *p << '\n';
    delete p;
}
```

**Output**
```
15
```

A pointer stores an address. `new` allocates memory, `*p` accesses its value, and `delete` releases it.

## 10. Default parameter and function overloading

```cpp
#include <iostream>
using namespace std;

int add(int a, int b = 0) { return a + b; }
double add(double a, double b) { return a + b; }

int main() {
    cout << add(7) << ' ' << add(2.5, 1.5) << '\n';
}
```

**Output**
```
7 4
```

A default parameter is used when an argument is absent. Overloading means the same function name has different parameter types or counts.

## 11. Class, object, encapsulation, and access specifiers

```cpp
#include <iostream>
using namespace std;

class Student {
private:
    int mark;
public:
    void setMark(int m) { mark = m; }
    int getMark() const { return mark; }
};

int main() {
    Student s;
    s.setMark(95);
    cout << s.getMark() << '\n';
}
```

**Output**
```
95
```

A class is a blueprint and `s` is an object. Keeping `mark` private and accessing it through public functions is encapsulation. The `const` function promises not to modify the object.

## 12. Constructor, destructor, and object lifetime

```cpp
#include <iostream>
using namespace std;

class Demo {
public:
    Demo() { cout << "Construct\n"; }
    ~Demo() { cout << "Destroy\n"; }
};

int main() {
    { Demo d; }
    cout << "After block\n";
}
```

**Output**
```
Construct
Destroy
After block
```

A constructor runs when an object is created. A destructor runs automatically when the object leaves its scope. That interval is the object's lifetime.

## 13. Copy constructor and deep copy

```cpp
#include <iostream>
using namespace std;

class Box {
    int* value;
public:
    Box(int v) : value(new int(v)) {}
    Box(const Box& other) : value(new int(*other.value)) {}
    void set(int v) { *value = v; }
    int get() const { return *value; }
    ~Box() { delete value; }
};

int main() {
    Box a(10);
    Box b = a;
    b.set(20);
    cout << a.get() << ' ' << b.get() << '\n';
}
```

**Output**
```
10 20
```

The copy constructor creates `b` from `a`. It allocates separate memory, so changing `b` does not change `a`; this is a deep copy.

## 14. Static member and static member function

```cpp
#include <iostream>
using namespace std;

class Counter {
    static int count;
public:
    Counter() { ++count; }
    static int total() { return count; }
};
int Counter::count = 0;

int main() {
    Counter a, b;
    cout << Counter::total() << '\n';
}
```

**Output**
```
2
```

A static data member is shared by every object. A static member function belongs to the class and is called using `ClassName::function()`.

## 15. Friend function

```cpp
#include <iostream>
using namespace std;

class Secret {
    int code = 42;
    friend void reveal(const Secret& s);
};
void reveal(const Secret& s) { cout << s.code << '\n'; }

int main() {
    Secret s;
    reveal(s);
}
```

**Output**
```
42
```

A friend function is not a member, but it is explicitly allowed to access private members.

## 16. Operator overloading

```cpp
#include <iostream>
using namespace std;

class Number {
    int value;
public:
    Number(int v) : value(v) {}
    Number operator+(const Number& other) const {
        return Number(value + other.value);
    }
    int get() const { return value; }
};

int main() {
    Number a(3), b(4);
    cout << (a + b).get() << '\n';
}
```

**Output**
```
7
```

Operator overloading defines what an operator such as `+` means for a user-defined class.

## 17. Namespace

```cpp
#include <iostream>
using namespace std;

namespace college { int year = 2026; }
namespace school  { int year = 2025; }

int main() {
    cout << college::year << ' ' << school::year << '\n';
}
```

**Output**
```
2026 2025
```

A namespace prevents names from conflicting. `::` is the scope-resolution operator.

## 18. Inheritance and constructor/destructor order

```cpp
#include <iostream>
using namespace std;

class Base {
public:
    Base() { cout << "Base constructor\n"; }
    ~Base() { cout << "Base destructor\n"; }
};
class Derived : public Base {
public:
    Derived() { cout << "Derived constructor\n"; }
    ~Derived() { cout << "Derived destructor\n"; }
};

int main() { Derived d; }
```

**Output**
```
Base constructor
Derived constructor
Derived destructor
Base destructor
```

Inheritance lets `Derived` reuse `Base`. Base construction happens first; destruction happens in reverse order.

## 19. Overriding and virtual-function polymorphism

```cpp
#include <iostream>
using namespace std;

class Animal {
public:
    virtual void sound() { cout << "Animal\n"; }
    virtual ~Animal() = default;
};
class Dog : public Animal {
public:
    void sound() override { cout << "Bark\n"; }
};

int main() {
    Animal* a = new Dog;
    a->sound();
    delete a;
}
```

**Output**
```
Bark
```

`Dog::sound` overrides the base virtual function. Although `a` is an `Animal*`, dynamic binding calls the `Dog` implementation at runtime.

## 20. Abstract base class and pure virtual function

```cpp
#include <iostream>
using namespace std;

class Shape {
public:
    virtual int area() const = 0;
    virtual ~Shape() = default;
};
class Square : public Shape {
    int side;
public:
    Square(int s) : side(s) {}
    int area() const override { return side * side; }
};

int main() {
    Square s(4);
    cout << s.area() << '\n';
}
```

**Output**
```
16
```

`area() = 0` is a pure virtual function. `Shape` is abstract and cannot be instantiated; `Square` provides the required implementation.

## 21. `static_cast` and `dynamic_cast`

```cpp
#include <iostream>
using namespace std;

class Base { public: virtual ~Base() = default; };
class Derived : public Base { public: void show() { cout << "Derived\n"; } };

int main() {
    double d = static_cast<double>(5) / 2;
    Base* b = new Derived;
    if (Derived* p = dynamic_cast<Derived*>(b)) p->show();
    cout << d << '\n';
    delete b;
}
```

**Output**
```
Derived
2.5
```

`static_cast` performs known compile-time conversions. `dynamic_cast` safely checks a downcast in a polymorphic class hierarchy; it gives `nullptr` if it fails.

## 22. Multiple and virtual inheritance

```cpp
#include <iostream>
using namespace std;

class Device { public: int id = 7; };
class Phone : virtual public Device {};
class Camera : virtual public Device {};
class SmartPhone : public Phone, public Camera {};

int main() {
    SmartPhone s;
    cout << s.id << '\n';
}
```

**Output**
```
7
```

`SmartPhone` has two parents. Virtual inheritance gives it only one shared `Device` object, solving the diamond problem.

## 23. Exception handling

```cpp
#include <iostream>
#include <stdexcept>
using namespace std;

int main() {
    try {
        int age = -1;
        if (age < 0) throw invalid_argument("Age cannot be negative");
    } catch (const exception& e) {
        cout << e.what() << '\n';
    }
}
```

**Output**
```
Age cannot be negative
```

`try` contains risky code, `throw` sends an exception, and `catch` handles it.

## 24. Function template

```cpp
#include <iostream>
using namespace std;

template <typename T>
T maximum(T a, T b) { return a > b ? a : b; }

int main() {
    cout << maximum(3, 7) << ' ' << maximum(2.5, 1.5) << '\n';
}
```

**Output**
```
7 2.5
```

A function template lets one function operate on different types. The compiler generates the needed version.

## 25. Class template

```cpp
#include <iostream>
using namespace std;

template <typename T>
class Pair {
    T first, second;
public:
    Pair(T a, T b) : first(a), second(b) {}
    T sum() const { return first + second; }
};

int main() {
    Pair<int> p(4, 6);
    cout << p.sum() << '\n';
}
```

**Output**
```
10
```

A class template is a generic class. `Pair<int>` creates an integer version.

## 26. Functor (function object)

```cpp
#include <iostream>
using namespace std;

class MultiplyBy {
    int factor;
public:
    MultiplyBy(int f) : factor(f) {}
    int operator()(int x) const { return x * factor; }
};

int main() {
    MultiplyBy twice(2);
    cout << twice(9) << '\n';
}
```

**Output**
```
18
```

A functor is an object that can be called like a function because it overloads `operator()`.

## 27. File streams

```cpp
#include <fstream>
#include <iostream>
using namespace std;

int main() {
    ofstream out("score.txt");
    out << 95;
    out.close();

    ifstream in("score.txt");
    int score;
    in >> score;
    cout << score << '\n';
}
```

**Output**
```
95
```

`ofstream` writes to a file and `ifstream` reads from it. The program first stores `95`, then reads and prints it.

## 28. `vector`, `set`, and `map`

```cpp
#include <iostream>
#include <map>
#include <set>
#include <vector>
using namespace std;

int main() {
    vector<int> v = {10, 20};
    set<int> s = {3, 1, 3};
    map<string, int> marks = {{"Asha", 90}};
    cout << v.size() << ' ' << s.size() << ' ' << marks["Asha"] << '\n';
}
```

**Output**
```
2 2 90
```

`vector` is a resizable array. `set` stores unique sorted values, so repeated `3` is removed. `map` stores key-value pairs.

## 29. STL algorithm and iterator

```cpp
#include <algorithm>
#include <iostream>
#include <vector>
using namespace std;

int main() {
    vector<int> v = {3, 1, 3, 2};
    sort(v.begin(), v.end());
    cout << count(v.begin(), v.end(), 3) << ' ' << *find(v.begin(), v.end(), 2) << '\n';
}
```

**Output**
```
2 2
```

An iterator identifies positions in a container. `begin()` and `end()` define the range. STL algorithms operate on that iterator range.

## 30. `auto`, `nullptr`, and range-based `for`

```cpp
#include <iostream>
#include <vector>
using namespace std;

int main() {
    auto number = 7;
    int* p = nullptr;
    vector<int> v = {1, 2, 3};
    for (int x : v) cout << x;
    cout << ' ' << number << ' ' << (p == nullptr) << '\n';
}
```

**Output**
```
123 7 1
```

`auto` lets the compiler infer a type. `nullptr` is a type-safe null pointer. A range-based `for` visits each collection element.

## 31. Move constructor and rvalue reference

```cpp
#include <iostream>
using namespace std;

class Data {
public:
    Data() { cout << "created\n"; }
    Data(const Data&) { cout << "copied\n"; }
    Data(Data&&) noexcept { cout << "moved\n"; }
};

int main() {
    Data a;
    Data b = static_cast<Data&&>(a);
}
```

**Output**
```
created
moved
```

An lvalue is a named object such as `a`. An rvalue reference is `Type&&`; it allows the move constructor to transfer a temporary object's resources instead of copying.

## 32. Lambda and captures

```cpp
#include <iostream>
using namespace std;

int main() {
    int bonus = 5;
    auto total = [bonus](int mark) { return mark + bonus; };
    cout << total(90) << '\n';
}
```

**Output**
```
95
```

A lambda is an unnamed function. `[bonus]` captures the outside variable by value. `[&bonus]` would capture it by reference.

## 33. Smart pointers and RAII

```cpp
#include <iostream>
#include <memory>
using namespace std;

int main() {
    auto oneOwner = make_unique<int>(10);
    auto sharedA = make_shared<int>(20);
    auto sharedB = sharedA;
    cout << *oneOwner << ' ' << sharedA.use_count() << '\n';
}
```

**Output**
```
10 2
```

`unique_ptr` has one owner. `shared_ptr` can have many owners and counts them. RAII means these objects release memory automatically when they leave scope.

## 34. Thread, mutex, and critical section

```cpp
#include <iostream>
#include <mutex>
#include <thread>
using namespace std;

int total = 0;
mutex m;

void add1000() {
    lock_guard<mutex> lock(m);
    for (int i = 0; i < 1000; ++i) ++total;
}

int main() {
    thread t1(add1000), t2(add1000);
    t1.join();
    t2.join();
    cout << total << '\n';
}
```

**Output**
```
2000
```

A thread is an independent execution path. The mutex protects the critical section that changes shared `total`; without it, a race condition could give a wrong result. `join()` waits for each thread to finish.

## Final 10-minute revision

1. Base constructor → derived constructor; derived destructor → base destructor.
2. `virtual` means runtime polymorphism; `= 0` means pure virtual/abstract.
3. Overloading changes parameters; overriding changes a virtual base function in a derived class.
4. A pointer stores an address; a reference is an alias.
5. `new` needs `delete`; smart pointers automate this.
6. `vector` is dynamic, `set` is unique/sorted, `map` is key-value.
7. Template = generic code; lambda = unnamed function; functor = callable object.
8. `try`/`throw`/`catch` handle exceptional errors.
9. `std::move` enables move semantics; it does not move by itself.
10. `mutex` prevents unsafe simultaneous shared-data access.
