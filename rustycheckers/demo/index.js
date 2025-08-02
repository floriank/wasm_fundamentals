(async function() {
    const response = await fetch("./rustycheckers.wasm");
    const bytes = await response.arrayBuffer();

    try {
        const result = await WebAssembly.instantiate(bytes, {
            env: {
                notify_piece_moved: (fX, fY, tX, tY) => {
                    console.log(`A piece moved from (${fX}, ${fY}) to (${tX}, ${tY})`);
                },

                notify_piece_crowned: (x, y) => {
                    console.log(`A piece was crowned at (${x}, ${y})`);
                },
            }
        });
        const { instance } = result;
        const { exports: { get_piece, move_piece, get_current_turn } }= instance;

        console.log("instance loaded, exports", instance.exports);
        let piece = get_piece(0, 7);
        console.log("Piece a (0, 7) is", piece);
        let res = move_piece(0, 5, 1, 4); //Black
        console.log("first move result:", res);
        console.log("next turn is", get_current_turn());

        let badMove = move_piece(1, 4, 2, 3); // bad move as it's illegal
        console.log("bad move result:", badMove);

        console.log(`At the end the turn owner is "${get_current_turn()}"`);

    } catch (e) {
        console.error(e);
    }
}())
