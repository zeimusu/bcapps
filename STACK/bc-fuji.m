(*

https://astronomy.stackexchange.com/questions/23165/viewing-diamond-fuji

TODO: refraction, Earth's curvature, Earth's ellipticity, ask Japanese Twitter peeps, DEM files for viewer, historical images

TODO: similar mountains incl Rainier?

TODO: shape of sun shadow, general concept of non flat horizon

Earth orientation: "standard" pos:

{0,0,1}: north pole

{1,0,0}: prime meridian/equator

{0,1,0}: prime meridian/+90E

sph2xyz[0,90*Degree,1]
sph2xyz[0,0*Degree,1]
sph2xyz[90*Degree,0,1]

local at lat lon converted

test[lat_,lon_] = rotationMatrix[z,-lon].rotationMatrix[y,lat-Pi/2]

test[0,lon].{0,0,1}


test[45*Degree, 45*Degree].{0,0,1}

y = -Sin[5*Degree] + b (for example)


*)

(* some approximations *)

(* 

NOTES:

highest mountain in Japan at 3,776.24 m (12,389 ft)

35�21#29#N 138�43#52#ECoordinates: 35�21#29#N 138�43#52#E#[2]

so at 5 degrees...

tan 5 = height / dist so dist = height / tan 5 or 43.162 km

14km at 15 degrees

6.5km at 30 degrees

flon = (138+43/60+52/3600)*Degree
flat = (35+21/60+29/3600)*Degree

(* kilometers *)
fele = 3776240/1000000

sph2xyz[flon, flat, rad[flat]+fele]

6371.009km = assumed radius for now

-Sin[5*Degree]*x+6371.009+fele

Solve[(-Sin[5*Degree]*x+6371.009+fele)^2 + x^2 == 6371.009^2]

Solve[(-Sin[60*Degree]*x+6371.009+fele)^2 + x^2 == 6371.009^2]

y[x_, theta_] = -Sin[theta]*x + 1.1

(* er is earth radius *)

y[x_, theta_, er_, elev_] = -Sin[theta]*er + (er + elev)

Solve[x^2 + y[x,theta,er,elev]^2 == er^2, x]

y[x_, theta_] = -Sin[theta]*rad[flat] + rad[flat] + fele

Solve[x^2 + y[x,theta]^2 == rad[flat]^2, x]

conds = {x>0, m<0, b>r}
Solve[x^2 + (m*x+b)^2 == r^2, x]




g0 = Graphics[{
 Circle[{0,0},1],
 Line[{{0,1},{0,1.1}}],
 Line[{ {-1, y[-1, 30*Degree]}, {1, y[1,30*Degree]}}]
}]

Show[g0]
showit

Solve[x^2 + y[x,30*Degree]^2 == 1, x]






*)

(*

diamond fuji pics:

https://ca.wikipedia.org/wiki/Diamond_Fuji Catalan

https://commons.wikimedia.org/wiki/File:Diamond_Fuji.jpg#globalusage

convert from frame at lan/lon/el to "earth frame"

local frame: north is y axis (map style)

testing/guessing

test = rotationMatrix[z,lon].rotationMatrix[x,lat-Pi/2]

test.{0,1,0} /. lat -> 0

THIS IS WRONG!!

that takes north to

test.{0,1,0}

what we need

at lat/lon 0, {0,1,0} goes to {0,0,1}

anywhere on eq in fact


*)


(* based on spiral paper work, er = earth rad, h = height *)

y[x_,theta_] = er+h-x*Tan[theta]

(* distance squared from center fo earth for any x *)

dist2[x_, theta_] = x^2 + y[x,theta]^2

conds = {x > 0, theta > 0, er > 0, h > 0}

solx[theta_] = Simplify[x /. Solve[dist2[x,theta] == er^2, x][[1]],conds]

soly[theta_] = Simplify[y[solx[theta],theta], conds]

(* need 90 minus below *)

dist[theta_] = FullSimplify[er*(Pi/2-ArcTan[soly[theta]/solx[theta]]), conds]

Plot[dist[theta] /.  {h -> 3776240/1000000, er -> 6371.009}, 
 {theta,3*Degree,15*Degree}]




FullSimplify[Pi/2-ArcTan[soly[theta]/solx[theta]], conds] /. 
 {h -> 3776240/1000000, er -> 6371.009}



min touch angle should be ArcCos[r/(r+h)]

min dist is thus r*ArcCos[r/(r+h)]


g0 = Graphics[{
 Circle[{0,0},1],
 Arrowheads[{-0.02, 0.02}],
 Arrow[{{0,0}, {0,1}}],
 Text[Style["r", FontSize -> 25], {0.03,0.5}],
 Text[Style["theta", FontSize -> 10], {-0.01, 1.16}],
 Line[{{-1,0}, {1,0}}],
 Arrow[{{-1, 1.15+Tan[37*Degree]}, {1, 1.15-Tan[37*Degree]}}],
 Arrow[{{0,0}, {0.2368, 0.971558}}],
 Dashed,
 Line[{{0,1.15}, {-1,1.15}}],
 Dashing[{}],
 Brown,
 Arrow[{{0,1}, {0,1.15}}],
 Text[Style["h", FontSize -> 25*Sqrt[.15]], {0.03,1.075}],
}]

Show[g0, PlotRange -> {{-1.1, 1.1}, {0, 2}}, ImageSize -> {800,600}]
showit

1.15-Sin[15*Degree]*-1

Sin[15*Degree]
0.258819

x sols are 0.2368 and 0.868651

y sol is .971558


NOT: 0.163448 is x sol,
NOT: 0.986552 is y sol
