(async function() {
    const white = 2;
    const black = 1;
    const crownedWhite = 6;
    const crownedBlack = 5;
    try {
        console.log("Fetching WASM file...");
        const response = await fetch("./func_test.wasm");
        console.log("Response status:", response.status);

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const bytes = await response.arrayBuffer();
        console.log("Bytes loaded:", bytes.byteLength);

        const { instance } = await WebAssembly.instantiate(bytes);
        console.log("WASM instantiated successfully");
        console.log("Exports:", Object.keys(instance.exports));
        console.log("Full exports object:", instance.exports);
        console.log("calling offset");
        const { offsetForPosition, isWhite, isBlack, withoutCrown, isCrowned } = instance.exports;
        const offset = offsetForPosition(3, 4);
        console.log("offset for position 3 and 4:", offset);

        console.debug({
            "White is white": isWhite(white),
            "Black is black": isBlack(black),
            "Black is white": isWhite(black),
            "Uncrowned White": isWhite(withoutCrown(crownedWhite)),
            "Uncrowned Black": isBlack(withoutCrown(crownedBlack)),
            "White Crowned is crowned": isCrowned(crownedWhite),
            "Black Crowned is crowned": isCrowned(crownedBlack),
        });
    } catch (e) {
        console.error(e);

    }

}());
