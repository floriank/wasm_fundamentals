(async function() {
    const response = await fetch("./checkers.wasm");
    const bytes = await response.arrayBuffer();

    try {
        const result = await WebAssembly.instantiate(bytes, {
            events: {
                pieceMoved: (fX, fY, tX, tY) => {
                    console.log(`A piece moved from (${fX}, ${fY}) to (${tX}, ${tY})`);
                },

                pieceCrowned: (x, y) => {
                    console.log(`A piece was crowned at (${x}, ${y})`);
                },
            }
        });
        const { instance } = result;

        console.log("instance loaded, exports", instance.exports);
        const { initBoard, move, getTurnOwner } = instance.exports;
        console.log("starting with ...", getTurnOwner);
        initBoard();

        move(0, 5, 0, 4); // B
        move(1, 0, 1, 1); // W
        move(0, 4, 0, 3); // B
        move(1, 1, 1, 0); // W
        move(0, 3, 0, 2); // B
        move(1, 0, 1, 1); // W
        move(0, 2, 0, 0); // B - this will get a crown
        move(1, 1, 1, 0); // W

        const res = move(0, 0, 0, 2);
        document.getElementById("container").innerText = res;
        console.log(`At the end the turn owner is "${getTurnOwner()}"`);

    } catch (e) {
        console.log(e);
    }
}())
