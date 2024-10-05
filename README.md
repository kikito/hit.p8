
# Hit

Hello Pico-8 community!

Rectangles ("Axis-Aligned Bounding Boxes", or aabbs, or simply boxes) are the most common way to detect collisions in videogames. Checking that two rectangles intersect is easy and fast.

However sometimes game objects need to move fast. Projectiles or even hedgehogs sometimes move so fast that they traverse many pixels per frame. When they move fast enough they can "phase through" objects, if one uses simple rectangle intersection as a mean to detect collisions.

Even when the two rectangles intersect, it can be tedious/tricky to find exactly on which position do they land.

I present you hit. It's a single function which will solve this particular problem, doing *continuous collision detection* instead of simple intersection.

<iframe src="https://www.lexaloffle.com/bbs/widget.php?pid=hit" allowfullscreen width="621" height="513" style="border:none; overflow:hidden"></iframe>

# Parameters and return values

```
tx,ty,nx,ny,t,intersect = hit(x1,y1,w1,h1,x2,y2,w2,h2,goalx,goaly)
```

Hit takes 10 parameters:
- `x1,y1,w1,h1`: A first rectangle, represented by its top-left coordinate, a width and height
- `x2,y2,w2,h2`: A second rectangle
- `goalx,goaly`: A point in space where the first rectangle "wants to move" (x1,y1 "wants to become" goalx,goaly)

Hit returns nil if the first rectangle can move freely to goalx,goaly without touching the second rectangle. If the rectangles touch at any point during this journey, hit will return:
- `tx,ty`: the coordinates where the first rectangle's top-left corner would be when it starts touching the second rectangle
- `nx,ny`: the "normals" of the contact. Given that we are dealing with aabbs, both nx and ny can only have -1,0 or 1
- `t`: "how far along" the journey did the contact occur. 0 means that the two boxes touch right at the beginning of the journey, and 1 means they touch at the end. In some degenerate cases t can also be bigger than 1 or smaller than 0 (see below). This parameter is useful for sorting collisions (the one with the smaller t will usually have "happened" first)
- `intersect`: `true` if the boxes were intersecting at the beginning of the journey, `false` if they were not. This parameter is useful to treat intersections differently from non-intersections in the collision resolution

# Usage

Save the hit function to a single file (hit.lua) and then
```
#include hit.lua
```

# Cost

Hit costs 422 tokens approximately. Most of the tokens come from the calculation of tx,ty,nx and ny. If those are not needed, then it can be strip down to a much leaner function that only returns true or false.

The function has several comments which can be stripped in order to save characters if necessary.

Performance-wise, it is not very expensive. There will be always some calls to abs, and number comparisons. For non-degenerate cases there will always be 4 divisions per collision detection.

# Notes and degenerate cases

When dealing with collision detection, there's many edge cases to take into account. Some of them are not obvious:
- No displacement vector: `x1,y1` is equal to `goalx,goaly` already. In this case, hit will return nil if the aabbs don't intersect. If they do intersect, however, then hit will return "the shortest path that would move the first aabb out of the second aabb". This can be either up, down, left or right, depending on what the nearest path is.
- First aabb is already intersecting the second aabb at the beginning of the journey. In this case hit will also try to move it towards the shortest exit, but *in the direction of the displacement*. Note however this can also send the object *backwards* in the direction it wants to go, if that's the sortest path out. Also note that when the objects are intersecting it is possible that t is either smaller than 0 or bigger than 1
- Corners: hit does not make any guarantees about collisions being detected if they happen to touch in a single point (e.g. the journey would make two corners coincide) or in a single line (the first aabb moves in such a way that it "slides" over the second, without trying to intersect it). On this cases it may or may not report a collision. 
- Precision: given Pico-8's limited floating point representation, the coordinates `tx` and `ty` will often not coincide precisely with what would result by multiplying the displacement vector (`goalx-x1,goaly-y1`) by `t`. Hit will "hide" this problem by moving things slightly in order to make the touch "feel" correct despite that, as much as the floating point representation permits.

# Preemptive FAQ

## How does hit work?

Hit combines two algorithms: The Minkowsky Difference and the Liang-Barsky line clipping algorithm.

The Minkowsky difference is a geometrical operation, where one object "gets smoothed over" the perimeter of another object. If you do the minkowsky difference between a square and a circle you will get a bigger square with rounded corners. When you do the minkowsky difference between two aabbs you get another (bigger) aabb.

The neat thing about this is that if you make one of the rectangles "bigger", you can make the other "smaller", and the properties of the collision work the same (as long as you respect some norms). If we make one of the rectangles as big as the Minkowsky diff, we can make the other one as small as a single point.

Which means that our "how do I collide these two moving boxes with each other" gets simplified to "how do I intersect this bigger box with this pixel that is moving, in other words, this segment".

The family of algorithms that solve this particular problem is called "line-clipping algorithms", and the Liang-Barsky one seems to be the fastest generic one. So we clip the diff with the segment, which gives us `t` and the normals. We then calculate `tx` and `ty`, paving over the floating point imprecision as much as possible.

## Why no guarantees on the corner cases?

I have done this kind of thing before, and it is simply too time consuming for me. I would rather stop here.

## Where have you done this kind of thing before?

I am the original author of the [bump.lua](https://github.com/kikito/bump.lua) library, used for collision detection in Lua/LÖVE , which is quite famous. There's some things I learned while writing that library, that I have tried to avoid/simplify while doing this Pico8 version.


## Bump.lua had collision resolution. Why doesn't hit have that?

Bump.lua is also much bigger, and includes a whole spacial hash implementation as well.

## Have you used this on an actual videogame?

I am building one, this is but one of the pieces. 

