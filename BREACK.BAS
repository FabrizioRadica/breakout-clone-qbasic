DECLARE FUNCTION MULTIKEY! (T!)
DECLARE SUB vblank ()
DECLARE SUB killgadget (id!, x!, y!, lung!, alt!, cols!, clickme!)
DECLARE FUNCTION gadgethit! ()
DECLARE SUB gadgetfill (id!, x!, y!, lung!, alt!, cols!, clickme!)
                                  
SCREEN 13
'DEFINT A-Z
maxgad = 200
suono = 1

TYPE gadgetStruct
  id AS INTEGER
  x AS INTEGER
  y AS INTEGER
  alt AS INTEGER
  lung AS INTEGER
  cols AS INTEGER
  exist AS INTEGER
  clickme AS INTEGER
END TYPE
DIM SHARED gadget(maxgad) AS gadgetStruct
DIM nomi$(30)
DIM punti(30)
DIM note(20)

OPEN "score.dat" FOR INPUT AS #1
  INPUT #1, record
  INPUT #1, livello
  INPUT #1, nome$
CLOSE
maxscore = record

init:
Z = MULTIKEY(-2)
CLS
IF suono = 1 THEN
   SOUND 40, 10
END IF
LOCATE 10, 15: PRINT "BREAK-OUT"
LOCATE 11, 11: PRINT "by Fabrizio Radica"
LOCATE 14, 12: PRINT "P=Pausa ESC=Esci"
LOCATE 16, 6: PRINT
SLEEP
Z = MULTIKEY(-1)
CLS
gran = 2
vx = 5
vy = 5
x = 160
y = 120

by = 170
bx = 50
byy = 100
bxx = 50

byy2 = 120
bxx2 = 50

bonusx = -20
bonusy = 100
bonusr = 6

score = 0
liv = 1
infra = 1
vita = 5
vvx = 0

main:
'Fondo
V = 0
FOR T = 0 TO 20 STEP 4
  FOR tt = 0 TO 320 STEP 4
    PSET (tt, 180 + T), 19 + V / 8
 NEXT
  V = V - 1
NEXT

obj = 1
RANDOMIZE TIMER
FOR T = 0 TO RND * 40 STEP 8 + RND * 12
 FOR tt = 0 TO 300 STEP 18 + RND * 24
  CALL gadgetfill(obj, tt, 20 + T, 16, 6, 3 + co, 0)
  LOCATE 1, 1: PRINT "Block"; obj
  obj = obj + 1
 NEXT
 co = co + 1
NEXT
nb = obj

IF suono = 1 THEN
FOR m = 1 TO 6
  READ note(m)
  SOUND note(m), 2
NEXT
RESTORE
END IF

DO
LINE (x, y)-(x + gran, y + gran), 0, BF
' Giocatore
LINE (100 + bx, by)-(135 + bx, by + 3), 0, BF
LINE (100 + bxx, byy)-(135 + bxx, byy + 3), 0, BF
LINE (100 + bxx2, byy2)-(135 + bxx2, byy2 + 3), 0, BF
CIRCLE (bonusx, bonusy), bonusr, 0

bxx = 50 + SIN(TIMER) * 128
byy = 100 + SIN(bxx / 32) * 32
bonusx = bonusx + 2
bonusr = 8 + SIN(bonusx)
bonusy = 100 + SIN(bonusx / 32) * 32

IF liv = 2 OR liv = 4 OR liv = 6 OR liv = 8 OR liv = 12 OR liv = 15 OR liv = 20 OR liv = 30 OR liv = 50 THEN
   att = 1
   bxx2 = bx * 1.5
   ELSE
   bxx2 = bxx * SIN(TIMER)
END IF


IF MULTIKEY(77) THEN bx = bx + 9
IF MULTIKEY(75) THEN bx = bx - 9
IF a$ = "p" OR a$ = "P" THEN
   LOCATE 15, 18: PRINT "Pausa"
   SLEEP
   LOCATE 15, 18: PRINT "     "
END IF

LINE (100 + bx, by)-(135 + bx, by + 3), 5, BF
LINE (100 + bxx, byy)-(135 + bxx, byy + 3), 8, BF
LINE (100 + bxx2, byy2)-(135 + bxx2, byy2 + 3), 9, BF
CIRCLE (bonusx, bonusy), bonusr, 6

x = x + vx
y = y + vy
CALL vblank
LINE (x, y)-(x + gran, y + gran), 15, BF

'Bonus
'IF x > bonusx AND x < bonusx + bonusr AND y > bonusy OR y < bonusy + bonusr THEN
'   vy = -vy
'   CIRCLE (bonusx, bonusy), bonusr, 0
'   score = score + 100
'   bonusx = -20
'END IF

' Collide Barra
IF x > bx + 100 AND x < bx + 135 + gran AND y > by - 8 AND y < by THEN
   IF suono = 1 THEN
      SOUND 200, 2
   END IF
   vy = -vy
END IF

' Barra Grigia
IF x > bxx + 100 AND x < bxx + 135 + gran AND y > byy - 8 AND y < byy THEN
   IF suono = 1 THEN
      SOUND 150, 2
   END IF
   vy = -vy
END IF

' Barra Blu
IF x > bxx2 + 100 AND x < bxx2 + 135 + gran AND y > byy2 - 8 AND y < byy2 THEN
   IF suono = 1 THEN
      SOUND 100, 2
   END IF
   vy = -vy
END IF

' Collide Icone
hit = gadgethit
IF hit > 0 AND hit < obj THEN
  IF gadget(hit).clickme = 0 THEN
  IF suono = 1 THEN
     SOUND 100, 2
  END IF
  CALL killgadget(hit, 0 + gadget(hit).x, 0 + gadget(hit).y, 0 + gadget(hit).lung, 0 + gadget(hit).alt, 0, 1)
  vy = -vy
  nb = nb - 1
  score = score + 10
  END IF
END IF

' Bordi
IF bonusx > 360 THEN bonusx = -20

IF x > (320 - gran) THEN vx = -vx: IF suono = 1 THEN SOUND 300, 2
IF x < 0 THEN vx = -vx: IF suono = 1 THEN SOUND 300, 2
IF y < 8 THEN vy = -vy: IF suono = 1 THEN SOUND 300, 2
IF y > 184 THEN
   IF suono = 1 THEN
      SOUND 50, 2
   END IF
   vita = vita - 1
   y = 90
END IF
IF score = 200 OR score = 1000 OR score = 2500 OR score = 5000 OR score = 10000 THEN
   score = score + 150
END IF
IF vita = 0 THEN GOTO morto

IF nb = 1 THEN
 GOTO nextlevel
END IF

LOCATE 1, 1: PRINT "Block"; nb - 1
LOCATE 1, 14: PRINT "Punti: "; score
LOCATE 1, 28: PRINT "Livello: "; liv
LOCATE 23, 1: PRINT "V:"; vita
LOCATE 23, 8: PRINT nome$; maxscore
LOCATE 23, 32: PRINT "Liv:"; livello

FOR cc = 0 TO 9
FOR ccc = 0 TO 600
NEXT
NEXT

LOOP UNTIL MULTIKEY(1) = 1
Z = MULTIKEY(-2)
END

morto:
Z = MULTIKEY(-2)
CLS
LOCATE 12, 16: PRINT "GAME OVER"
LOCATE 14, 14: PRINT "Record: "; score
LOCATE 15, 14: PRINT "Livello: "; liv
IF score > maxscore THEN
   maxscore = score
   livello = liv
   LOCATE 17, 12: INPUT "nome: "; nome$
   OPEN "score.dat" FOR OUTPUT AS #1
      PRINT #1, maxscore
      PRINT #1, liv
      PRINT #1, nome$
   CLOSE
END IF
SLEEP
CLS
GOTO init

nextlevel:
liv = liv + 1
infra = infra + 1
y = 90
IF liv = 5 OR liv = 10 OR liv = 20 OR liv = 30 OR liv = 50 THEN
  IF suono = 1 THEN
     SOUND 800, 10
  END IF
  vita = vita + 1
END IF

' Musica
DATA 600,400,800,600,400,900,-1

CLS
GOTO main

SUB gadgetfill (id, x, y, lung, alt, cols, clickme)
gadget(id).id = id
gadget(id).x = x
gadget(id).y = y
gadget(id).lung = lung
gadget(id).alt = alt
gadget(id).cols = cols
gadget(id).exist = 1
gadget(id).clickme = clickme
SHARED movex, ngad

xinterline = 8
yinterline = 14
center = 5

IF gadget(id).exist = 1 THEN
   LINE (x + 1, y + 1 - center)-(lung + x - 1, y + alt - 1 - center), gadget(id).cols, BF
   LINE (x, y - center)-(lung + x, y - center)
   LINE (x, y - center)-(x, alt + y - center), 8
   LINE (x, alt + y - center)-(lung + x, alt + y - center), 8
   LINE (lung + x, alt + y - center)-(lung + x, y - center)
END IF

END SUB

'
FUNCTION gadgethit
SHARED y, x, gran, obj, vx, vy
FOR hit = 0 TO obj
 IF y < gadget(hit).y + 8 THEN
   IF x > gadget(hit).x AND x < gadget(hit).lung + gadget(hit).x + 10 AND y > gadget(hit).y - 8 AND y < gadget(hit).alt + gadget(hit).y + 18 THEN
      gadgethit = hit
   END IF
 END IF
NEXT


END FUNCTION

SUB killgadget (id, x, y, lung, alt, cols, clickme)
gadget(id).id = id
gadget(id).x = x
gadget(id).y = y
gadget(id).lung = lung
gadget(id).alt = alt
gadget(id).cols = cols
gadget(id).exist = 1
gadget(id).clickme = clickme
SHARED movex, ngad

xinterline = 8
yinterline = 14
center = 5

IF gadget(id).exist = 1 THEN
   LINE (x, y - center)-(lung + x, y + alt - center), gadget(id).cols, BF
END IF

END SUB

FUNCTION MULTIKEY (T)
STATIC kbcontrol%(), kbmatrix%(), Firsttime, StatusFlag

IF Firsttime = 0 THEN          'Initalize
 DIM kbcontrol%(128)
 DIM kbmatrix%(128)
 code$ = ""
 code$ = code$ + "E91D00E93C00000000000000000000000000000000000000000000000000"
 code$ = code$ + "00001E31C08ED8BE24000E07BF1400FCA5A58CC38EC0BF2400B85600FAAB"
 code$ = code$ + "89D8ABFB1FCB1E31C08EC0BF2400BE14000E1FFCFAA5A5FB1FCBFB9C5053"
 code$ = code$ + "51521E560657E460B401A8807404B400247FD0E088C3B700B0002E031E12"
 code$ = code$ + "002E8E1E100086E08907E4610C82E661247FE661B020E6205F075E1F5A59"
 code$ = code$ + "5B589DCF"
 DEF SEG = VARSEG(kbcontrol%(0))
 FOR I% = 0 TO 155                     ' Load ASM
     d% = VAL("&h" + MID$(code$, I% * 2 + 1, 2))
     POKE VARPTR(kbcontrol%(0)) + I%, d%
 NEXT I%
 I& = 16       ' I think this stuff connects the interrupt with kbmatrix%()
 n& = VARSEG(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE I&, l&: POKE I& + 1, h&: I& = I& + 2
 n& = VARPTR(kbmatrix%(0)): l& = n& AND 255: h& = ((n& AND &HFF00) \ 256): POKE I&, l&: POKE I& + 1, h&: I& = I& + 2
 DEF SEG
 Firsttime = 1
END IF

SELECT CASE T
 CASE -1
  IF StatusFlag = 0 THEN
   DEF SEG = VARSEG(kbcontrol%(0))
   CALL ABSOLUTE(0)                     ' Run interrupt
   DEF SEG
   StatusFlag = 1
  END IF
 CASE -2
  IF StatusFlag = 1 THEN
   DEF SEG = VARSEG(kbcontrol%(0))      ' Turn off interrupt
   CALL ABSOLUTE(3)
   DEF SEG
   StatusFlag = 0
  END IF
 CASE 1 TO 128
  MULTIKEY = kbmatrix%(T)               ' Return status
 CASE ELSE
  MULTIKEY = 0                          ' User Supidity Error
END SELECT
END FUNCTION

SUB vblank
' Vblank
WAIT &H3DA, 8
END SUB

