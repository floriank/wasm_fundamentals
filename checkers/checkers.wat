(module
    (import "events" "pieceMoved" (func $notifyPieceMoved (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32)))
    (import "events" "pieceCrowned" (func $notifyPieceCrowned (param $pieceX i32) (param $pieceY i32)))
    (global $WHITE i32
        (i32.const 2))
    (global $BLACK i32
        (i32.const 1))
    (global $CROWN i32
        (i32.const 4))

    (memory $memory 1)
    (global $currentTurn (mut i32)
        (i32.const 0))
    ;; get the current turn owner
    (func $getTurnOwner (result i32)
        (global.get $currentTurn))
    ;; toggle the owner at the end of a turn
    (func $toggleOwner
        (if
            (i32.eq
                (call $getTurnOwner)
                (i32.const 1))
            (then
                (call $setTurnOwner
                    (i32.const 2)))
            (else
                (call $setTurnOwner
                    (i32.const 1)))))
    ;; set the turn owner
    (func $setTurnOwner (param $owner i32)
        (global.set $currentTurn
            (local.get $owner)))
    ;; should this piece be crowned (black in the 0 row, white in the 7 row
    (func $shouldCrown (param $pieceY i32) (param $piece i32) (result i32)
        (i32.or
            (i32.and
                (i32.eq
                    (local.get $pieceY)
                    (i32.const 0))
                (call $isBlack
                    (local.get $piece)))
            (i32.and
                (i32.eq
                    (local.get $pieceY)
                    (i32.const 7))
                (call $isWhite
                    (local.get $piece)))))
    ;; crowns a piece
    (func $crownPiece (param $x i32) (param $y i32) (local $piece i32)
        (local.set $piece
            (call $getPiece
                (local.get $x)
                (local.get $y)))
        (call $setPiece
            (local.get $x)
            (local.get $y)
            (call $withCrown
                (local.get $piece)))
        (call $notifyPieceCrowned
            (local.get $x)
            (local.get $y)))
    ;; distance check
    (func $distance (param $x i32) (param $y i32) (result i32)
        (i32.sub
            (local.get $x)
            (local.get $y)))
    ;; check if it's the player's turn
    (func $isPlayerTurn (param $player i32) (result i32)
        (i32.gt_s
            (i32.and
                (local.get $player)
                (call $getTurnOwner))
            (i32.const 0)))
    ;; Determine if a piece is crowned
    (func $isCrowned (param $piece i32) (result i32)
        (i32.eq
            (i32.and
                (local.get $piece)
                (global.get $CROWN))
            (global.get $CROWN)))

    ;; Determine if a piece is white
    (func $isWhite (param $piece i32) (result i32)
        (i32.eq
            (i32.and
                (local.get $piece)
                (global.get $WHITE))
            (global.get $WHITE)))
    ;; Determine if a piece is black
    (func $isBlack (param $piece i32) (result i32)
        (i32.eq
            (i32.and
                (local.get $piece)
                (global.get $BLACK))
            (global.get $BLACK)))
    ;; adds a crown to a piece
    (func $withCrown (param $piece i32) (result i32)
        (i32.or
            (local.get $piece)
            (global.get $CROWN)))
    ;; removes a crown from a piece
    (func $withoutCrown (param $piece i32) (result i32)
        (i32.and
            (local.get $piece)
            (i32.const 3)))
    (func $indexForPosition (param $x i32) (param $y i32) (result i32)
        (i32.add
            (i32.mul
                (i32.const 8)
                (local.get $y))
            (local.get $x)))
    ;; Offset = (x + y * 8) * 4
    (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
        (i32.mul
            (call $indexForPosition
                (local.get $x)
                (local.get $y))
            (i32.const 4)))
    ;; check range
    (func $inRange
        (param $low i32) (param $high i32) (param $value i32) (result i32)
        (i32.and
            (i32.ge_s
                (local.get $value)
                (local.get $low))
            (i32.le_s
                (local.get $value)
                (local.get $high))))
    ;; sets a piece on the board
    (func $setPiece (param $x i32) (param $y i32) (param $piece i32)
        (i32.store
            (call $offsetForPosition
                (local.get $x)
                (local.get $y))
            (local.get $piece)))
    ;; get a piece from the board
    (func $getPiece (param $x i32) (param $y i32) (result i32)
        (if (result i32)
            (block (result i32)
                (i32.and
                    (call $inRange
                        (i32.const 0)
                        (i32.const 7)
                        (local.get $x))
                    (call $inRange
                        (i32.const 0)
                        (i32.const 7)
                        (local.get $x))))
            (then
                (i32.load
                    (call $offsetForPosition
                        (local.get $x)
                        (local.get $y))))
            (else
                (unreachable))))
    ;; determine whether move is valid
    (func $isValidMove
        (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
        (local $player i32) (local $target i32)
        (local.set $player
            (call $getPiece
                (local.get $fromX)
                (local.get $fromY)))
        (local.set $target
            (call $getPiece
                (local.get $toX)
                (local.get $toY)))

        (if (result i32)
            (block (result i32)
                (i32.and
                    (call $validJumpDistance
                        (local.get $fromY)
                        (local.get $toY))
                    (i32.and
                        (call $isPlayerTurn
                            (local.get $player))
                        ;; needs to be free space
                        (i32.eq
                            (local.get $target)
                            (i32.const 0)))))
            (then
                (i32.const 1))
            (else
                (i32.const 0))))
    ;; max travel is 1 or 2 squares
    (func $validJumpDistance (param $from i32) (param $to i32) (result i32)
        (local $_distance i32)
        (local.set $_distance
            (if (result i32)
                (i32.gt_s
                    (local.get $to)
                    (local.get $from))
                (then
                    (call $distance
                        (local.get $to)
                        (local.get $from)))
                (else
                    (call $distance
                        (local.get $from)
                        (local.get $to)))))
        (i32.le_u
            (local.get $_distance)
            (i32.const 2)))

    ;; move function for the game host
    (func $move
        (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
        (if (result i32)
            (block (result i32)
                (call $isValidMove
                    (local.get $fromX)
                    (local.get $fromY)
                    (local.get $toX)
                    (local.get $toY)))
            (then
                (call $do_move
                    (local.get $fromX)
                    (local.get $fromY)
                    (local.get $toX)
                    (local.get $toY)))
            (else
                (i32.const 0))))
    ;; internal move function, do actually change game state
    (func $do_move
        (param $fromX i32) (param $fromY i32) (param $toX i32) (param $toY i32) (result i32)
        (local $currentPiece i32)
        (local.set $currentPiece
            (call $getPiece
                (local.get $fromX)
                (local.get $fromY)))
        (call $toggleOwner)
        (call $setPiece
            (local.get $toX)
            (local.get $toY)
            (local.get $currentPiece))
        (call $setPiece
            (local.get $fromX)
            (local.get $fromY)
            (i32.const 0))
        ;; crown check
        (if
            (call $shouldCrown
                (local.get $toY)
                (local.get $currentPiece))
            (then
                (call $crownPiece
                    (local.get $toX)
                    (local.get $toY))))
        (call $notifyPieceMoved
            (local.get $fromX)
            (local.get $fromY)
            (local.get $toX)
            (local.get $toY))
        (i32.const 1))

    (func $initBoard
        ;; place the white pieces top of board
        (call $setPiece
            (i32.const 1)
            (i32.const 0)
            (i32.const 2))
        (call $setPiece
            (i32.const 3)
            (i32.const 0)
            (i32.const 2))
        (call $setPiece
            (i32.const 5)
            (i32.const 0)
            (i32.const 2))
        (call $setPiece
            (i32.const 7)
            (i32.const 0)
            (i32.const 2))

        (call $setPiece
            (i32.const 0)
            (i32.const 1)
            (i32.const 2))
        (call $setPiece
            (i32.const 2)
            (i32.const 1)
            (i32.const 2))
        (call $setPiece
            (i32.const 4)
            (i32.const 1)
            (i32.const 2))
        (call $setPiece
            (i32.const 6)
            (i32.const 1)
            (i32.const 2))

        (call $setPiece
            (i32.const 1)
            (i32.const 2)
            (i32.const 2))
        (call $setPiece
            (i32.const 3)
            (i32.const 2)
            (i32.const 2))
        (call $setPiece
            (i32.const 5)
            (i32.const 2)
            (i32.const 2))
        (call $setPiece
            (i32.const 7)
            (i32.const 2)
            (i32.const 2))

        ;; Place the black pieces at the bottom of the board
        (call $setPiece
            (i32.const 0)
            (i32.const 5)
            (i32.const 1))
        (call $setPiece
            (i32.const 2)
            (i32.const 5)
            (i32.const 1))
        (call $setPiece
            (i32.const 4)
            (i32.const 5)
            (i32.const 1))
        (call $setPiece
            (i32.const 6)
            (i32.const 5)
            (i32.const 1))

        (call $setPiece
            (i32.const 1)
            (i32.const 6)
            (i32.const 1))
        (call $setPiece
            (i32.const 3)
            (i32.const 6)
            (i32.const 1))
        (call $setPiece
            (i32.const 5)
            (i32.const 6)
            (i32.const 1))
        (call $setPiece
            (i32.const 7)
            (i32.const 6)
            (i32.const 1))

        (call $setPiece
            (i32.const 0)
            (i32.const 7)
            (i32.const 1))
        (call $setPiece
            (i32.const 2)
            (i32.const 7)
            (i32.const 1))
        (call $setPiece
            (i32.const 4)
            (i32.const 7)
            (i32.const 1))
        (call $setPiece
            (i32.const 6)
            (i32.const 7)
            (i32.const 1))
        (call $setTurnOwner
            (i32.const 1)) ;; Black goes first

    )

    (export "getPiece" (func $getPiece))
    (export "isCrowned" (func $isCrowned))
    (export "initBoard" (func $initBoard))
    (export "getTurnOwner" (func $getTurnOwner))
    (export "move" (func $move))
    (export "memory" (memory $memory)))

;; 200 = 11001000
