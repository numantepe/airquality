# Deterioration of Air Quality

A cellular automaton, written in [Processing](https://processing.org), that models how deforestation and water pollution affect air quality.

Cities grow out of the desert, cut down forests and pollute the seas, and they release smog into the air. Forests and clean water absorb that smog. Three awareness rates control how carefully people treat their environment, so you can see how much forest protection, wastewater treatment and smoke filtering change the result.

## Background

Smog is a mix of smoke and fog, mostly from burning coal, vehicle exhaust and factory emissions. Plants and algae absorb some of its gases (CO<sub>2</sub>, NO<sub>2</sub>, SO<sub>2</sub>) and release oxygen, which makes forests and healthy seas natural air filters. When forests are cut down or the water is contaminated, those filters disappear and the air gets worse.

## Running the simulation

1. Install [Processing](https://processing.org/download) (version 3 or later).
2. Open `airquality.pde` and press **Run**.

The map is generated at random every time you run the sketch.

## Configuration

These variables are at the top of `airquality.pde`:

| Variable | Default | Description |
| --- | --- | --- |
| `n` | `200` | Grid size (n × n cells) |
| `blinksPerSecond` | `60` | Frame rate (recommended 10–100) |
| `numOfCities` | `10` | Number of cities at the start |
| `deforestationAwarenessRate` | `100` | 0–100. Higher means fewer forests are cut down |
| `waterPollutionAwarenessRate` | `100` | 0–100. Higher means more wastewater is treated |
| `airPollutionAwarenessRate` | `100` | 0–100. Higher means fewer emissions (smoke filters etc.) |

Try setting all three awareness rates to `0` and compare the result with the defaults.

## Cell states

| Colour | State | Represents |
| --- | --- | --- |
| Gold | City | Cities, farmland and crop fields |
| Dark green | Forest | Healthy forest |
| Pale green-white | Desert | Barren land or destroyed forest |
| Sky blue | Water | Clean sea with plenty of algae |
| Dark purple | Contaminated water | Polluted water where the algae has died |
| Translucent grey | Smog | Air pollution, drawn over the terrain |

## Evolution rules

Each cell looks at its 8 neighbours. In the formulas below, *p* = 101 − the relevant awareness rate, so *p* is 1 at 100% awareness and 101 (always) at 0% awareness.

| # | Rule | Chance per frame |
| --- | --- | --- |
| 1 | Cities start in random desert cells. | — |
| 2 | **City growth:** a city turns one neighbouring desert into city. Each city is active in a frame with a chance of 1 / (10 + *t*/5), where *t* is the time in seconds, so growth slows down over time. | 50% per desert neighbour |
| 3 | **Deforestation:** a city turns one neighbouring forest into desert. | 50% × *p*% |
| 4 | **Water pollution:** a city contaminates one neighbouring water cell. | 0.1% |
| 5 | **Pollution spread:** contaminated water contaminates one neighbouring water cell. | (*p* / 40)% |
| 6 | **Contamination damage:** a forest next to contaminated water turns into desert. | 0.1% |
| 7 | **Emissions:** a city releases a smog particle, which then drifts across the map at a random speed. This chance falls over time. | (*p* / 2)% at the start |
| 8 | **Air cleaning:** smog over a forest or clean water is absorbed. | 50% |
| 9 | Deserts and contaminated water don't absorb smog. | — |
| 10 | **Natural recovery:** clean water cleans one neighbouring contaminated cell, and a forest regrows one neighbouring desert cell. | 0.02% |

## Sample evolution

| First generation | Second generation |
| :---: | :---: |
| <img src="images/first-generation.png" width="300" alt="Grid of 16 numbered cells, first generation" /> | <img src="images/second-generation.png" width="300" alt="The same 16 cells, second generation" /> |

The cells that changed between the two generations:

| Cell | Rule | Caused by |
| --- | --- | --- |
| 3 | #5 Pollution spread | Cell 2 |
| 7 | #4 Water pollution | Cell 6 |
| 11 | #3 Deforestation | Cell 11 |
| 12 | #8 Air cleaning | Cell 12 |
| 14 | #2 City growth | Cell 13 |

## What the model gets right

- Water pollution and deforestation make air quality worse, and protecting forests and water helps clear harmful gases from the air.
- Environmental precautions significantly slow down the damage, but they can't stop it completely. A growing population still uses up resources.
- As resources run out, consumption slows down. With every awareness rate at 0%, cities spread and forests disappear quickly at first, then the destruction slows.

## Limitations

- **Day and night:** plants and algae absorb CO<sub>2</sub> all the time in the model. In reality, photosynthesis only happens in daylight, and at night they release CO<sub>2</sub> through respiration.
- **Weather:** there is no weather. Rain, wind and seasons have no effect.
- **Population:** cities never shrink. In reality, populations can fall because of war or low birth rates.
- **Pollutants:** smog is modelled as only CO<sub>2</sub>, NO<sub>2</sub> and SO<sub>2</sub>. Real air pollution also includes CFCs, VOCs and other pollutants that plants can't absorb.

## License

[MIT](LICENCE.md) © 2023 Numan Tepe
