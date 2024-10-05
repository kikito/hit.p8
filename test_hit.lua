local x1,y1,w1,h1
local x2,y2,w2,h2
local goalx,goaly
local omx,omy,omp

local t,nx,ny,tx,ty,intersect -- t,normal,touch

local mode -- move green, red or goal

function _init()
  x1,y1,w1,h1=10,40,10,10
  x2,y2,w2,h2=62,70,30,30
  goalx,goaly=102,102
  mode=1
  poke(0x5f2d, 1)
end

function nice(x)
  return flr(x*100)/100
end

function _draw()
  cls()

  line(x1,y1,goalx,goaly,12)
  rect(x1,y1,x1+w1,y1+h1, mode==1 and 7 or 11)
  rect(x2,y2,x2+w2,y2+h2, mode==2 and 7 or 8)
  circ(goalx,goaly,2, mode==3 and 7 or 9)

  print(x1..","..y1..","..w1..","..h1,0,0,mode==1 and 7 or 11)
  print(x2..","..y2..","..w2..","..h2,0,8,mode==2 and 7 or 8)
  print(goalx..","..goaly,0,16,mode==3 and 7 or 9)


  if ti then
   if intersect then
    line(x1,y1,tx,ty,1)
   end
   line(tx,ty,tx+nx*5,ty+ny*5,10)
   fillp(▒)
   rect(tx,ty,tx+w1,ty+h1,12)
   fillp()
   circ(tx+nx*5,ty+ny*5,1,10)

   color(7)
   print("nx,ny: "..nx..","..ny, 60,0,10)
   print("tx,ty: "..nice(tx)..","..nice(ty), 60,8,12)
   print("ti: " .. ti, 60,16, 12)
   print("intersect: "..tostr(intersect), 60,24,1)
  end
end

function _update()
 local mx,my=stat(32),stat(33)
 if not omx then
  omx,omy=mx,my
 end
 if mx~=omx or my~=omy then
  if mode == 1 then
    x1=mx
    y1=my
  elseif mode == 2 then
    x2=mx
    y2=my
  else
    goalx=mx
    goaly=my
  end
  omx,omy=mx,my
 else
  local dx=btn(➡️) and 1 or btn(⬅️) and -1 or 0
  local dy=btn(⬇️) and 1 or btn(⬆️) and -1 or 0
 
  if mode == 1 then
    x1 += dx
    y1 += dy
  elseif mode == 2 then
    x2 += dx
    y2 += dy
  else
    goalx += dx
    goaly += dy
  end
 end

 local mp=stat(34)>0
 if btnp(❎) or mp and not omp then
  mode=mode%3+1
 end
 omp=mp

 ti,nx,ny,tx,ty,intersect = hit(x1,y1,w1,h1,x2,y2,w2,h2,goalx,goaly)
end
