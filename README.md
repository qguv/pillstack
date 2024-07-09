# pillstack

![3d render of object](https://qguv.github.io/pillstack/img/pillstack.png)

a from-scratch redesign of https://www.printables.com/model/116168-stackable-supplement-containers in OpenSCAD

changes from the original:

- all dimensions are customizable
- the default set is much more compact
- optional textured exterior
- the flat bottom is now hollow to maximize interior space
- unified interior and exterior wall size

## building

once you have the submodules (`git submodule update --init`), run `ninja` or `openscad -o pillstack.3mf pillstack.scad`

## animation

some animations are included at the beginning of pillstack.scad. you can uncomment them (one at a time) to view them. from the OpenSCAD GUI, select View → Animate, then set FPS to 30 and Steps to 360

note: this seems to prevent OpenSCAD from automatically updating the preview when the source changes
