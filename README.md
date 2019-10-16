# MiniPython-Interpreter
Compiler Lab 1

## Function
1. 包含：
    - 数值(`INT`和`REAL`)
    - 串(`STRING_LITERAL`)
    - 列表(`List`)
    - ……
    
   等数据类型
2. 包含加减乘除等基本运算
3. 支持取列表元素、取列表片段等操作
4. 支持列表的方法（至少实现`append()`方法）和内置函数（`range()`, `print()`, `len()`, `list()`等）调用

## Deadline
- 10月底：完成相关数据结构（属性）的设计并提交备查
- 11月底：检查实验

## Members
- 嵇帆
- 罗晏宸
- 牛辛汉

***
## How to Build & Run
```shell
yacc -d minipy-lab.y
lex minipy-lab.l
g++ y.tab.c
./a.out
```
or use Make:
```shell
make all
```
To make clean:
```shell
make clean
```
## About Git
### Commit Form
```
Type<scope>:Title
	Body
```
- `Type`：用于说明commit的类别
    - `FEAT`：新增功能
    - `FIX`：修复bug
    - `DOCS`：修改项目文档
    - `REFACTOR`：局部功能代码重构，未新增任何功能和修复任何bug
    - `STYLE`：仅仅修改了空格、缩进等，或增加注释，修改变量名等增加代码可读性的文字修改，不改变代码逻辑
    - `REVERT`：回滚到上一个版本
- `scope`：用于说明本次commit的影响范围，例如<minipython-lab.y>
- `Title`：本次commit的简要标题，尽量简短，例如“修改了算术运算符的产生式”
- `Body`：详细描述本次commit，多行

### Tags
在完成相关数据结构（属性）的设计后，也即10月底前，项目tag应迭代至0.5.0以上，完整功能的项目tag不低于1.0.0

## Reference
- [CPython](https://github.com/python/cpython/)
    - [Grammer](https://github.com/python/cpython/tree/master/Grammer)
    - [Parser](https://github.com/python/cpython/tree/master/Parser)
- [Python Docs](https://docs.python.org/3/)
    - [Literals](https://docs.python.org/3/reference/lexical_analysis.html#literals)