(module
  (global $WHITE i32 (i32.const 2))
  (global $BLACK i32 (i32.const 1))
  (global $CROWN i32 (i32.const 4))

  (memory $men 1)
  ;; Determine if a piece is crowned
  (func $isCrowned (param $piece i32) (result i32)
        (i32.eq
          (i32.and (local.get $piece) (global.get $CROWN))
          (global.get $CROWN)
        )
    )

  ;; Determine if a piece is white
  (func $isWhite (param $piece i32) (result i32)
        (i32.eq
          (i32.and (local.get $piece) (global.get $WHITE))
          (global.get $WHITE)
        )
    )
  ;; Determine if a piece is black
  (func $isBlack (param $piece i32) (result i32)
        (i32.eq
          (i32.and (local.get $piece) (global.get $BLACK))
          (global.get $BLACK)
        )
    )
  ;; adds a crown to a piece
  (func $withCrown (param $piece i32) (result i32)
        (i32.or (local.get $piece) (global.get $CROWN))
    )
  ;; removes a crown from a piece
  (func $withoutCrown (param $piece i32) (result i32)
        (i32.and (local.get $piece) (i32.const 3))
    )
  (func $indexForPosition (param $x i32) (param $y i32) (result i32)
        (i32.add
          (i32.mul
            (i32.const 8)
            (local.get $y)
          )
          (local.get $x)
        )
    )
  ;; Offset = (x + y * 8) * 4
  (func $offsetForPosition (param $x i32) (param $y i32) (result i32)
        (i32.mul
            (call $indexForPosition (local.get $x) (local.get $y))
            (i32.const 4)
        )
    )
)
