import { Engine as GameEngine, PlayerCore } from './dist/roguewasm';
import { Display, Engine, RNG } from 'rot-js';
import Simple from 'rot-js/lib/scheduler/simple';
import Digger from 'rot-js/lib/map/digger';

export class Game {
    private display: Display = null;
    private engine: GameEngine = null;
    private player: PlayerCore = null;
    private enemy: any = null;
    private rotengine: Engine = null;

    init = () => {
        this.display = new Display({ width: 125, height: 40 });
        document.getElementById('rogueCanvas').appendChild(this.display.getContainer());
        this.engine = new GameEngine(this.display);
        this.generateMap();
        this.engine.draw_map();

        const scheduler = new Simple();
        scheduler.add(this.player, true);
        scheduler.add(this.enemy, true);

        this.rotengine = new Engine(scheduler);
        this.rotengine.start();
    }
    private generateMap = () => {
        const digger = new Digger(125, 40);
        const freeCells: String[] = [];

        const digCallback = (x: number, y: number, value: number) => {
            if (!value) {
                const key = `${x},${y}`;
                freeCells.push(key);
            }
            this.engine.on_dig(x, y, value)
        }
        digger.create(digCallback);
        this.generateBoxes(freeCells);
    }
    private generateBoxes = (cells: String[]) => {

        for (let i = 0; i < 10; i++) {
            const index = Math.floor(RNG.getUniform() * cells.length);
            const key = cells.splice(index, 1)[0];
            const parts = key.split(',');
            const x = parseInt(parts[0], 10);
            const y = parseInt(parts[1], 10);
            this.engine.place_box(x, y);
            if (i === 9) {
                this.engine.mark_wasm_prize(x, y);
            }


        }
    }
}

new Game().init();
