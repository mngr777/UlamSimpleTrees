![ant](https://user-images.githubusercontent.com/1970037/225900641-fa48f082-9cda-40fe-a545-be0ae0a2d5f8.png)

A collection of demos for Moveable Feast Machine.
The demos show executing programs represented as trees of bonded atoms.

TLDR:
* Programs are represented as binary trees built from bonded atoms.
* Program trees are executed by an interpreter atom crawling between nodes along the bonds.
* Trees are constructed from sequences that represent input to the system.
* Here's a [video](#ant-ad-element) of an artificial ant following a trail by executing a program tree. Full [5 min. run on YouTube](https://www.youtube.com/watch?v=1OOWWHmasfc).

# Building and running
On Ubuntu, intstall `ulam` package (it contains both ULAM and MFM) from PPA, see [ULAM Tutorial](https://github.com/elenasa/ULAM/wiki/Ulam-Programming-Language).  
Or install ULAM and MFM from source: http://robust.cs.unm.edu/doku.php?id=dev:install_ulam. Note that for `develop` branch, `Makefile.local.mk` should use `$ULAM_ROOT_DIR` instead of `$ROOT_DIR`.

After that, running `make` in repo directory will compile `*.ulam` source files and run the result in MFM.

# Classes

## QBond
Half a link between two atoms. Stores a site number of other atom (at default event window symmetry) and an index of corresponding `QBond` in `IBondable` interface of that atom.

## IBondable and QBondableT
An interface and implementation (template) for a container of `QBond` objects. This allows elements to have a different number of bonds.

## Sequence and Tree
![sequence](https://user-images.githubusercontent.com/1970037/226056347-dda3892c-c464-4c90-b1dd-328bf005e9cd.png)
![tree](https://user-images.githubusercontent.com/1970037/226056371-4862d47a-a0bb-4415-a97a-19bbb64cb59d.png)


Simple data containers that can be bonded together. The data is `Datum` type that combines data and metadata in a single `Bits(16)` value. `Tree` element additionally has a second field to hold a result of subtree evaluation. Both elements have an additional bond so that they can be attached to an atom using them.

There's actually no need to have two different types, this is just a bit simpler to implement.

## TreeBuilder and QTreeBuilder
![tree-builder](https://user-images.githubusercontent.com/1970037/225903165-1e3d222f-2dbb-4ca7-a399-fe4ea73a4a28.png)

A state machine for building trees from sequences is implemented in `QTreeBuilder` quark, so builders extending it can have additional states and functionality -- this is used to set up the demos.

## IDiffusable and QDiffusableT
Diffusion implementation that is aware of bonds. Bonded atoms prefer not to stretch their bonds to length 4, this seems to help when an agent has to drag along a sequence or a tree, since there's usually some slack to pull initially.

## BondUtils
Functions for moving atoms within or between groups of bonded atoms by manipulating their links. It's normal for this functions to fail as they require 3 atoms to be within current event window. Returned status can be checked to decide if it makes sense to retry.

## DataUtils and TreeData
Accessing bytes and bits in `Datum` type.

## EventWindowInverse
Maps site number stored in `QBond` to current symmetry. There should be a simpler way, but I couldn't find it.

## EventWindowMisc
Functions to find an empty site to build on.

## SwapHelper
Swaps two atoms using `EventWindow.swap`. Checks the bonds before swapping and updates them after.

## SequenceBuilder
Builds a sequence while keeping it attached to a bondable atom, simulating input.

## Mover
![mover](https://user-images.githubusercontent.com/1970037/225904224-e2feebbd-bf3e-4214-8746-88c37e439f1e.png)

Moves (diffusable) stuff it's attached to. It is used in demos to drag away input sequences that are no longer used.


# Demos

### Sequence to Tree (TS element)
`TreeBuilder` object produces a tree from a sequence it's attached to.

### Ant (AD element)
A program tree is constructed and used to drive an "artificial ant" agent. `Ant` element has an interpreter for a simple language that consists of `if-food-ahead` conditional and functions `forward`, `left`, `right` and `progn` to glue them together.


https://user-images.githubusercontent.com/1970037/225955700-d0e9890f-a50f-4881-bba6-b5ae76b6e5ed.mp4



## Demos using "general purpose" interpreter
The following three demos feature a "general purpose" interpreter `TreeExec`. They all are set up in a same way:
* Demo element builds a sequence containing a program for `TreeExec` to execute.
* `ExecTestTreeBuilder` is attached to the sequence and builds a program tree.
* The builder constructs a short input sequence for the interpreter.
* It then constructs the interpreter and provides it with a program to execute and an input.

There's an option to reuse the program sequence as input: select "EP" element in "Tools" and check parameter box.

### The interpreter
The `TreeExec` interpreter has 4 bonds: for program tree, memory sequence, input sequence and output tree. There's also state number, two "registers" and and index of currently selected bond. The output is a tree just because I wanted to have a demo with building a copy of the program that the builder itself is running (see [below](#building-a-tree-e3-element)); trees and sequences should be replaced with a single type anyway.

Functions that are not supposed to fail like `+` or `-` can have their arguments directly passed to them: `(+ 1 2)`, `(- (num-attached) 2)`. Functions that create new atoms and manipulate links instead read their arguments from registers and memory and expect input or output bond to be selected, e.g. moving to next atom in input sequence looks like this:
```
(prog2
  (prog2
    (input)        ; select input
    (set-1 2))     ; set register 1 value to bond index of next atom
  (if-has-attached ; is there anything attached to "next" bond?
    (traverse)     ; move
    (noop)))
```
Here `traverse` puts `TreeExec` into `cSTATE_TRAVERSE` state until it succeeds or fails and goes into
`cSTATE_EXEC` or `cSTATE_ERROR`. This is not designed very well and not lispy at all but works for the demos so I'm leaving it as is.

### Moving to the beginning of input sequence (E1 element)
`TreeExec` (white `TE` atom) is attached to the last atom in a sequence and crawls to the beginning. Program tree: [ExecDemo.ulam:416](https://github.com/mngr777/UlamSimpleTrees/blob/71290ee7ed5fb6046185bf887ed8ca035ae11ee7/ExecDemo.ulam#L416)

![rewind-last](https://user-images.githubusercontent.com/1970037/226033015-d22504db-862a-44c5-9899-a9eb4afcb677.png)
![rewind-middle](https://user-images.githubusercontent.com/1970037/226030409-92f031bc-0272-424d-8d3d-82863d540be0.png)


### Storing a copy of input sequence in memory (E2 element)
Program tree: [ExecDemo.ulam:444](https://github.com/mngr777/UlamSimpleTrees/blob/71290ee7ed5fb6046185bf887ed8ca035ae11ee7/ExecDemo.ulam#L444)

![memory](https://user-images.githubusercontent.com/1970037/225993551-6af718db-0828-4264-bd9b-7de2ada78894.png)


### Building a tree (E3 element)
`TreeExec` gets a program that implements mostly the same algorithm as `TreeBuilder` and runs it on input sequence. Program: [ExecDemo.ulam:486](https://github.com/mngr777/UlamSimpleTrees/blob/3c029cb939154290f75354d2252ce2f8511b7665/ExecDemo.ulam#L486)

Here's a picture of `TreeExec` in the beginning of building a tree from a sequence containing it's own program:

![building-tree](https://user-images.githubusercontent.com/1970037/226048972-d5380cf6-a411-4dee-a0bc-b211bf2c41c7.png)



