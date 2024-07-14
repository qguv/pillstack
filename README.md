# pillstack

_also available [on Printables](https://www.printables.com/model/937925-pillstack)_

![3d render of object](https://qguv.github.io/pillstack/img/pillstack.png)

Customizable 3d-printable model for stackable threaded containers. Use for pills, medicine, supplements, or any small parts. 

## inspiration

This project is an improved from-scratch redesign of https://www.printables.com/model/116168-stackable-supplement-containers in OpenSCAD, so that users can customize the dimensions without compromising the threads.

Changes from the original:

- all dimensions are customizable
- the default set is much more compact
- optional textured exterior
- the flat bottom is now hollow to maximize interior space
- unified interior and exterior wall size

## building

Once you have the submodules (`git submodule update --init`), run `ninja` or `openscad -o pillstack.3mf pillstack.scad`
