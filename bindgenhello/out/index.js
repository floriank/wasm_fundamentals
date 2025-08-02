(async function() {
    const wasm = import("./wasm/bindgenhello");
    try {
        const mod = await wasm;
        mod.hello("world");
    } catch (e) {
        console.error(e)
    }
}());
