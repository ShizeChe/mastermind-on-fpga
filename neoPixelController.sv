`default_nettype none

/**
* The module specification is as listed in the Lab5 handout, with the added
* benefit that resetting the controller causes the Neopixels to clear. This has
* the side effect of the controller essentially not working until ready is
* asserted after reset, but with a 50 MHz clock this is probably fine.
*
* Just make sure that "ready" is asserted before you hit "go".
*/
module NeopixelController (
    input   logic [7:0] red, blue, green,
    input   logic [2:0] pixel,
    input   logic       CLOCK_50, reset,
    input   logic       load, go,
    output  logic       neopixel_data, ready
);
O
I
(
.
l
(
CLOCK_50
)
,
.
o
(
reset
)
,
.
i
(
load
)
,
.
OI
(
go
)
,
.
II
(
ready
)
,
.
lI
(
red
)
,
.
oI
(
green
)
,
.
iI
(
blue
)
,
.
Ol
(
pixel
)
,
.
Il
(
neopixel_data
)
)
;
endmodule
:
NeopixelController
module
O
#
(
parameter
ll
=
8
,
parameter
ol
=
$clog2
(
ll
)
,
parameter
il
=
8
,
parameter
O0
=
20
)
(
input
logic
l,
o,
input
logic
i,
OI,
output
logic
II,
input
logic
[
il
-
1
:
0
]
lI,
oI,
iI,
input
logic
[
ol
-
1
:
0
]
Ol,
output
logic
Il
)
;
localparam
I0
=
700
;
localparam
l0
=
600
;
localparam
o0
=
350
;
localparam
i0
=
800
;
localparam
O1
=
50000
;
localparam
I1
=
3
*
il
;
localparam
l1
=
I0
/
O0
;
localparam
o1
=
l0
/
O0
;
localparam
i1
=
o0
/
O0
;
localparam
Oo
=
i0
/
O0
;
localparam
Io
=
O1
/
O0
;
enum
int
{
lo
,
oo
,
io
,
Oi
,
Ii
,
li
}
oi
,
ii
;
logic
[
ll
-
1
:
0
]
[
I1
-
1
:
0
]
OOI
,
IOI
;
logic
[
I1
-
1
:
0
]
lOI
;
logic
[
ol
:
0
]
oOI
,
iOI
;
logic
[
4
:
0
]
OII
,
III
;
logic
lII
;
logic
[
31
:
0
]
oII
,
iII
;
logic
OlI
,
IlI
;
logic
llI
,
olI
;
logic
ilI
,
O0I
;
logic
I0I
,
l0I
;
logic
o0I
,
i0I
;
always_ff
@
(
posedge
l
,
posedge
o
)
begin
if
(
o
)
oi
<=
lo
;
else
oi
<=
ii
;
end
always_ff
@
(
posedge
l
,
posedge
o
)
begin
if
(
o
)
begin
IOI
<=
'0
;
iOI
<=
'0
;
III
<=
5
'
(
I1
-
1
)
;
iII
<=
'0
;
end
else
begin
IOI
<=
OOI
;
iOI
<=
(
OlI
)
?
'0
:
oOI
;
III
<=
(
llI
)
?
5
'
(
I1
-
1
)
:
OII
;
iII
<=
(
ilI
)
?
'0
:
oII
;
end
end
always_comb
begin
ii
=
oi
;
unique
case
(
oi
)
lo
:
begin
ii
=
oo
;
end
oo
:
begin
ii
=
(
lII
)
?
Oi
:
Ii
;
end
io
:
begin
if
(
OI
)
begin
ii
=
(
lII
)
?
Oi
:
Ii
;
end
end
Oi
:
begin
if
(
i0I
)
begin
if
(
I0I
)
ii
=
li
;
else
ii
=
(
lII
)
?
Oi
:
Ii
;
end
end
Ii
:
begin
if
(
o0I
)
begin
if
(
I0I
)
ii
=
li
;
else
ii
=
(
lII
)
?
Oi
:
Ii
;
end
end
li
:
begin
if
(
iII
==
Io
)
ii
=
io
;
end
endcase
end
always_comb
begin
olI
=
1
'b
0
;
IlI
=
1
'b
0
;
O0I
=
1
'b
0
;
llI
=
1
'b
0
;
OlI
=
1
'b
0
;
ilI
=
1
'b
0
;
OOI
=
IOI
;
Il
=
1
'b
0
;
II
=
1
'b
0
;
unique
case
(
oi
)
lo
:
begin
llI
=
1
'b
1
;
OlI
=
1
'b
1
;
ilI
=
1
'b
1
;
end
oo
:
begin
olI
=
1
'b
1
;
end
io
:
begin
II
=
1
'b
1
;
if
(
OI
)
begin
olI
=
1
'b
1
;
end
if
(
i
)
begin
OOI
[
Ol
]
=
lOI
;
end
end
Oi
:
begin
O0I
=
1
'b
1
;
Il
=
(
iII
<
l1
)
;
if
(
i0I
)
begin
if
(
l0I
)
begin
llI
=
1
'b
1
;
IlI
=
~
I0I
;
end
olI
=
1
'b
1
;
ilI
=
1
'b
1
;
end
end
Ii
:
begin
O0I
=
1
'b
1
;
Il
=
(
iII
<
i1
)
;
if
(
o0I
)
begin
if
(
l0I
)
begin
llI
=
1
'b
1
;
IlI
=
~
I0I
;
end
olI
=
1
'b
1
;
ilI
=
1
'b
1
;
end
end
li
:
begin
O0I
=
1
'b
1
;
if
(
iII
==
Io
)
begin
II
=
1
'b
1
;
ilI
=
1
'b
1
;
OlI
=
1
'b
1
;
llI
=
1
'b
1
;
end
end
endcase
end
always_comb
begin
oOI
=
(
IlI
)
?
iOI
+
ol
'
(
'd
1
)
:
iOI
;
OII
=
(
olI
)
?
III
-
5
'd
1
:
III
;
oII
=
(
O0I
)
?
iII
+
32
'd
1
:
iII
;
end
assign
lOI
=
{
oI
,
lI
,
iI
}
;
assign
lII
=
IOI
[
iOI
]
[
III
]
;
assign
I0I
=
(
(
iOI
==
ll
)
&&
(
III
==
5
'
(
I1
-
1
)
)
)
;
assign
l0I
=
(
III
==
5
'd
0
)
;
assign
o0I
=
(
iII
>=
i1
+
Oo
)
;
assign
i0I
=
(
iII
>=
l1
+
o1
)
;
endmodule
:
O
