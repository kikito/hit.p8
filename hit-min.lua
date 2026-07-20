-- hit-min: t-only variant of hit().
-- returns entry time t (0..1) of aabb1 (x1,y1,w1,h1) moving toward
-- (goalx,goaly) against aabb2 (x2,y2,w2,h2). already-overlapping -> 0.
-- no hit -> nil. no normals/touch points. smaller t = hit sooner (nearer).
function hit(x1,y1,w1,h1, x2,y2,w2,h2, goalx, goaly)
  -- minkowsky difference aabb
  local x,y,w,h=x2-x1-w1,y2-y1-h1,w1+w2,h1+h2
  local dx,dy=goalx-x1,goaly-y1

  -- already overlapping -> hit now (t=0, closest possible)
  if x<0 and x+w>0 and y<0 and y+h>0 then return 0 end

  -- liang-barsky clip of the movement vs the minkowsky aabb
  local t1,t2=-32768,32767
  local p,q,r
  for side=1,4 do
    if     side==1 then p,q=-dx, -x
    elseif side==2 then p,q= dx,x+w
    elseif side==3 then p,q=-dy, -y
    else                p,q= dy,y+h
    end
    if p==0 then
      if q<=0 then return end
    else
      r=q/p
      if p<0 then
        if     r>t2 then return
        elseif r>t1 then t1=r end
      else
        if     r<t1 then return
        elseif r<t2 then t2=r end
      end
    end
  end

  if 0<=t1 and t1<=1 then return t1 end
end
