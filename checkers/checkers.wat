(module
    (global $WHITE i32
        (i32.const 2))
    (global $BLACK i32
        (i32.const 1))
    (global $CROWN i32
        (i32.const 4))

    (memory $men 1)
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
                (unreachable)))))

;; 200 = 11001000
