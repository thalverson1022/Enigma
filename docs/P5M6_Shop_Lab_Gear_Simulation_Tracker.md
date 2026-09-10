# P5M6: Shop Lab Gear Simulation Tracker

## Status

Complete.

P5M6 finishes when Shop Lab has been rebuilt as the first tuning and
feel-testing surface for the new Phase 5 gear economy. The lab should let us
roll many shop offers quickly, inspect whether generated gear creates readable
choices, and produce a concrete handoff for P5M7 live reward/shop integration.

P5M6 is not the final Adventure economy, final item-card presentation, Hood or
Doublet art, retained Legendary stat tuning, or full Practice Room/Balance Lab
validation. Those remain assigned to later Phase 5 milestones.

Post-completion playtest update: Chaos item simulation should mirror the live
generator's current rule that duplicate stat IDs are allowed on Chaos items.
Rare positive Chaos outcomes should be weighted 20% lower than Basic positive
and Basic drawback outcomes. Lucky Coin is a fixed Tavern Trinket/Ring reward,
not a Charm/Necklace reward.

Primary design document:

- `docs/New_Gear_Overview.md`

Related milestone document:

- `docs/P5_Gear_Redesign_Overview.md`

Previous milestone tracker:

- `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md`

Tooling surface:

- `tools/shop-lab/README.md`
- `tools/shop-lab/index.html`
- `tools/shop-lab/app.js`
- `tools/shop-lab/styles.css`

## Exit Criteria

- Current Shop Lab implementation has been audited and obsolete Phase 4
  assumptions are mapped.
- Shop Lab no longer presents as a quarantined Phase 4/DawnBringer tool.
- Shop Lab simulates five-slot Phase 5 gear offers: Weapon, Helm, Armor,
  Trinket, and Charm.
- Rogue item families display as Dagger, Hood, Doublet, Ring, and Necklace.
- Procedural rarity simulation covers Basic, Master, Epic, Cursed, Chaos, and
  Unique gear while preserving Crude, Lucky Coin, fixed gear, and Legendary
  boundaries.
- The lab can repeatedly roll shop offers from deterministic seeds.
- Tuning controls expose shop size, seed, contract depth, rarity odds, slot
  odds, value scaling, reroll/session setup, and batch simulation size.
- Contract-depth rarity curves can be simulated without committing final live
  Adventure values.
- Contract-depth value scaling can be adjusted and inspected.
- Generated item cards/readouts show rarity, slot, Rogue item family, positive
  stats, drawbacks, Specials, stat categories, and tuning-facing roll metadata.
- Aggregate readouts show rarity, slot, stat category, individual stat,
  drawback, Special, Cursed, Chaos, Unique, and retrigger-risk frequencies.
- Cursed and Chaos outcomes are visible enough to discuss whether their risk and
  reward feel good.
- Unique Special frequency is visible enough to decide whether Specials should
  remain Unique-only for the next integration pass.
- The lab exposes whether Basic-only drawbacks are enough or whether Rare-stat
  drawbacks should be designed later.
- The lab surfaces Chance for Retrigger cap risk in repeated offer rolls.
- Focused regression checks cover deterministic output, Phase 5 gear shape,
  Cursed/Chaos/Unique handling, depth/value controls, fixed-gear exclusion, and
  stale Phase 4 assumption removal.
- Phase 5 docs are updated with P5M6 completion notes and the P5M7 tuning
  handoff.

## Task Tracker

| Task | Status | Purpose | Output |
| --- | --- | --- | --- |
| P5M6-T1: Audit Current Shop Lab Surface | Complete | Map the existing browser lab and identify all stale Phase 4 assumptions before rewriting it. | Completed 2026-09-04. Audit notes below map stale Phase 4 assumptions in `tools/shop-lab`, current standalone behavior, reusable UI/simulation pieces, and the recommended hybrid bridge strategy for the Phase 5 generator rules. |
| P5M6-T2: Define Shop Simulation Inputs | Complete | Lock the tuning controls before implementation. | Completed 2026-09-04. Input model below defines seed, contract depth, shop size, rarity odds/curve presets, slot odds, value scale, reroll/session setup, batch size, deterministic key paths, output metadata, defaults, and T2 scope boundaries. |
| P5M6-T3: Port The Phase 5 Gear Model Into Shop Lab | Complete | Replace old three-slot/four-tier assumptions with the completed Phase 5 procedural item model. | Completed 2026-09-04 and updated after playtesting. `tools/shop-lab` now uses Phase 5 slots, Rogue families, procedural rarities, stat categories, slot pools, weights, rarity stat-count rules, value ranges, rarity multipliers, Cursed/Chaos drawbacks, Unique Specials, non-Chaos duplicate prevention, Chaos duplicate allowance, and fixed-boundary labels. |
| P5M6-T4: Implement Deterministic Offer Rolling | Complete | Make repeated shop rolls reproducible from stable settings. | Completed 2026-09-04. Shop Lab now centralizes deterministic key paths and includes scriptable checks proving same seed/settings reproduce offers, item IDs/signatures, and batch summaries while reroll/depth/value-scale changes produce distinct outputs. |
| P5M6-T5: Add Contract-Depth Rarity Curves | Complete | Explore how rarity odds should improve over contract depth before live Adventure integration. | Completed 2026-09-04. Curve mode now interpolates early/mid/late/high-variance rarity anchors by contract depth, manual mode preserves explicit weights, and the lab shows configured versus observed rarity odds in current controls and batch output. |
| P5M6-T6: Expose Contract-Depth Value Scaling | Complete | Tune item magnitude separately from rarity frequency. | Completed 2026-09-04. Shop Lab now applies and displays separate manual and contract-depth value multipliers, shows combined scaling with effective stat-range examples, and reports value-scaling summaries in batch output. |
| P5M6-T7: Make Generated Items Readable | Complete | Give tuning discussions clear item-level evidence. | Completed 2026-09-04. Offer cards now show rarity, slot, Rogue family, readable stat text, values, drawbacks, Specials, and retrigger-relevant stat text while keeping diagnostic metadata available to scripts/readouts rather than cluttering item cards. |
| P5M6-T8: Add Distribution And Frequency Readouts | Complete | Summarize repeated rolls so tuning is not based on one shop at a time. | Completed 2026-09-04. Session and batch readouts now aggregate rarity, slot, roll markers, stat categories, stat IDs, drawbacks, Specials, Unique Specials, Chaos outcomes, Cursed shape, retrigger appearances, value magnitude, and broad quality bands. |
| P5M6-T9: Add Cursed And Chaos Tuning Views | Complete | Inspect whether high-risk rarities are exciting rather than merely noisy. | Completed 2026-09-04. Dedicated Cursed and Chaos summaries now show item rates, Cursed shape validity, positive/drawback balance, magnitude averages, top risk stats, Chaos outcome mix, and all-positive/mixed/all-drawback rates. |
| P5M6-T10: Add Retrigger Risk Visibility | Complete | Watch the known Chance for Retrigger cap-risk item before full validation. | Completed 2026-09-04. Retrigger Watch now reports Chance for Retrigger appearances, item rate, slot/rarity mix, min/average/max values, multi-retrigger shops, top-five stack estimates, and proximity to the 100% cap. |
| P5M6-T11: Add Quick Simulation Presets | Complete | Make tuning comparisons fast and repeatable. | Completed 2026-09-04. Quick Simulation presets now apply Early Run, Mid Run, Late Run, and High Variance setups across depth, curve, manual value scale, shop size, batch size, and deterministic seed labels. |
| P5M6-T12: Add Focused Regression Checks | Complete | Prove the rebuilt lab and its exported assumptions stay aligned with Phase 5 rules. | Completed 2026-09-05. Added one-command Shop Lab check runner plus Phase 5 shape and stale-assumption checks covering deterministic repeatability, five-slot/rarity/family shape, Cursed/Chaos/Unique rendering, depth/value controls, random seed behavior, Lucky Coin/fixed-boundary exclusion, Legendary procedural exclusion, and removal of old Phase 4 assumptions. |
| P5M6-T13: Update Docs And Closeout | Complete | Record what the lab shows and prepare P5M7. | Completed 2026-09-05. This tracker, onboarding, Phase 5 overview, and gear overview record P5M6 completion notes, current tuning baseline, proposed P5M7 rarity/depth handoff, caveats, and resolved Shop Lab quarantine status. |

## Status Definitions

- `Ready`: The task can be worked now.
- `Blocked`: The task needs a prior task output, implementation decision, or
  design clarification before it can be completed.
- `In Progress`: The task is actively being audited, edited, implemented, or
  reviewed.
- `Complete`: The task output has been added, verified, and recorded.

## P5M6-T1 Audit Findings

Completed 2026-09-04.

Reference baseline:

- `docs/New_Gear_Overview.md` defines the target Shop Lab model: five universal
  slots, Rogue item families, Basic/Master/Epic/Cursed/Chaos/Unique procedural
  rarity rules, fixed Crude/Lucky Coin/Legendary boundaries, slot/category stat
  pools, value ranges, contract-depth value scaling, Cursed/Chaos drawbacks,
  Unique Specials, and retrigger-risk visibility.
- `docs/P5_Gear_Redesign_Overview.md` makes P5M6 the first feel-testing surface
  before P5M7 live reward/shop integration.
- `docs/P5M5_Gear_Generator_And_Rarity_Rules_Tracker.md` records the completed
  generator baseline that P5M6 should mirror or export from.
- `project/scripts/systems/gear_generator.gd` now exposes
  `generate_from_request()` with slot, rarity, RNG/seed, deterministic key/id,
  source metadata, `contract_depth`, and `value_scale`.
- `project/scripts/systems/stat_catalog.gd` now contains the authoritative
  Phase 5 stat IDs, labels, slot/category pools, weights, value kinds, value
  ranges, drawback eligibility, and Special definitions.

Current Shop Lab surface:

- `tools/shop-lab/README.md` accurately quarantines the lab as a Phase
  4/DawnBringer tool and states that P5M6 owns the Phase 5 rewrite.
- `tools/shop-lab/index.html` presents the page as `Project Enigma Phase 4 Shop
  Lab` with a `Phase 4 Tooling` eyebrow and current controls for starting gold,
  shop size, amazing-score threshold, item-type odds, slot odds, affix odds,
  reroll session state, distribution, and a fixed 1,000-shop quick simulation.
- `tools/shop-lab/app.js` is fully client-only and deterministic from a local
  string-hashed Mulberry32 RNG. Session generation increments a visible seed,
  rerolls cost `+5g` more each time, and quick simulation rolls 1,000 shops from
  derived seed strings.
- `tools/shop-lab/styles.css` is usable as a dense tuning dashboard shell with
  controls, offer cards, session metrics, distribution bars, and responsive
  columns, but its rarity and slot colors only cover the old surface.

Stale Phase 4 assumptions:

| Area | Current Assumption | Phase 5 Conflict | Triage |
| --- | --- | --- | --- |
| Tool identity | README and UI still describe Phase 4/DawnBringer-era shop tuning. | P5M6 should no longer present as quarantined Phase 4 tooling once rebuilt. | Migrate |
| Slots | JavaScript only rolls `weapon`, `trinket`, and `charm`. | Phase 5 requires Weapon, Helm, Armor, Trinket, and Charm. | Migrate |
| Rogue families | Display families only cover Dagger, Ring, and Necklace. | Phase 5 Rogue families are Dagger, Hood, Doublet, Ring, and Necklace. | Migrate |
| Rarities | Active tiers are Basic, Master, Cursed, and Legendary. | Procedural lab rolls should cover Basic, Master, Epic, Cursed, Chaos, and Unique; Crude is starter-only and Legendary is fixed-catalog boundary visibility, not procedural stat rolling. | Migrate |
| Legendary behavior | Legendary items can appear directly in weighted shop offers. | P5M6 may show the Legendary boundary but should not include procedural Legendary stat packages; final retained Legendary tuning is P5M10. | Migrate/Defer |
| Stat vocabulary | Affixes use old IDs such as `affix.poison_damage_per_tick`, `affix.armor_reduction`, and `affix.physical_skill_damage`. | Phase 5 uses canonical `StatCatalog` IDs such as `base_elemental_damage`, `increased_shred_stacks`, and `percent_physical_damage`. | Migrate |
| Stat pools | One global affix pool is rolled for every slot. | Phase 5 uses slot-specific Basic, Rare, and Special pools with documented weights. | Migrate |
| Stat categories | Generated affixes only distinguish positive and downside. | Phase 5 must expose Basic, Rare, Special, and drawback categories. | Migrate |
| Rarity shapes | Basic has 1 positive; Master has 2 positives; Cursed has one amplified positive, one Master positive, and one downside. | P5M5 defines Basic 1 Basic, Master 2 Basic, Epic 3 Basic + 1 Rare, Cursed 2 Basic + 1 Rare + 1 Basic drawback, Chaos 5 Basic/Rare/drawback outcomes, Unique 3 Basic + 1 Rare + 1 Special. | Migrate |
| Value model | Values come from fixed per-affix tables and special Cursed table names. | Phase 5 values roll from slot/stat ranges, apply rarity multiplier, apply `value_scale`, apply contract-depth value scaling, then round by value kind. | Migrate |
| Duplicate rules | Distinct picks apply inside the old local positive/downside path only. | Current rules forbid duplicate canonical stat IDs on non-Chaos items. Chaos intentionally allows duplicates across all five rolls. | Migrate |
| Weight controls | User-facing `Affix Odds` mutate global stat weights. | P5M6 needs slot/category pool visibility; editing every stat weight may be useful later, but the first input model should prioritize rarity odds, slot odds, depth, value scale, and batch size. | Migrate/Defer |
| Item metadata | Cards show rarity, slot, score, price, name, and affix labels. | P5M6 cards need tuning metadata: rarity, slot, Rogue family, stat ID, category, weight, value, drawback/Special markers, seed/key/signature, and boundary flags. | Migrate |
| Scoring | `Amazing Score`, item score, best item, and affordability drive readouts. | P5M6 needs distribution/frequency/readability signals without pretending to solve final item balance. Existing scoring can inspire a provisional quality signal only if clearly labeled. | Defer/Open Decision |
| Batch output | Quick Sim reports amazing-shop rate, affordable-amazing rate, median/P90 gold, and Legendary rate. | P5M6 requires aggregate rarity, slot, stat category, stat ID, drawback, Special, Unique Special, Cursed/Chaos outcome, and retrigger-risk frequencies. | Migrate |
| Contract depth | No depth input exists. | P5M6 needs contract-depth rarity curves and value scaling visibility. | Migrate |
| Fixed exclusions | Lucky Coin, Crude starter gear, compatibility gear, and Legendary boundaries are not visible as explicit exclusions. | P5M6 must preserve and explain these boundaries in the lab and regression checks. | Migrate |

Reusable pieces:

- The static browser delivery remains appropriate for P5M6; no server or build
  step is required unless a later export script is added.
- The three-column dashboard layout, slider stack pattern, offer-card renderer,
  session metrics, distribution bars, and quick-simulation panel can be reused.
- The deterministic local RNG approach is useful for the browser lab, but T4
  should define stable seed paths and item signatures that mirror P5M5 concepts
  closely enough for repeated shops and batch summaries.
- The reroll session loop and escalating reroll cost can remain as a tunable
  feel-test layer, while P5M6 keeps final live economy tuning deferred to P5M7.

Recommended bridge strategy:

- Use a hybrid bridge for T2-T3. Port the P5M5 generator algorithm into
  JavaScript for immediate client-only iteration, but move the Phase 5 catalog
  data into a single structured data block or JSON-like module that mirrors
  `StatCatalog` and `GearGenerator` constants.
- Do not hand-maintain opaque old affix tables. The browser model should be
  organized around canonical stat IDs, slot/category pools, pool weights, value
  ranges, rarity roll plans, rarity multipliers, Chaos outcome weights, and
  fixed boundary metadata.
- Add a later lightweight catalog parity check or export/check script during
  T12 if practical. The check should compare Shop Lab catalog data against
  `StatCatalog`/`GearGenerator` surfaces so tuning data cannot silently diverge.
- Keep Legendary as boundary/readout data in P5M6 rather than a normal
  procedural offer tier. If the lab needs a Legendary row, label it as
  fixed-catalog/P5M10-facing rather than letting it roll procedural stats.
- Treat `contract_depth` and `value_scale` as visible simulation inputs, with
  contract-depth rarity curves implemented in the lab and Godot's current
  generator depth value hook treated as the baseline to inspect rather than a
  final Adventure economy commitment.

Downstream implications:

- P5M6-T2 should define the new controls before code changes: seed, contract
  depth, shop size, rarity odds or curve preset, slot odds, value scale,
  reroll/session setup, and batch size.
- P5M6-T3 should replace the old data model in `app.js` rather than patching
  the current global affix arrays in place.
- P5M6-T7/T8/T9/T10 should rely on structured item roll metadata so item cards,
  aggregate readouts, Cursed/Chaos inspection, Unique Special frequency, and
  Chance for Retrigger risk do not need to reverse-engineer labels later.
- P5M6-T12 should include stale-assumption checks for removal of three-slot
  arrays, old affix IDs, procedural Legendary rolling, and Phase 4/DawnBringer
  presentation language.

## P5M6-T2 Shop Simulation Input Model

Completed 2026-09-04.

T2 locks the Shop Lab input contract before the Phase 5 generator model is
ported into the browser. These controls are tuning inputs for a lab surface, not
final live Adventure economy values.

Canonical inputs:

| Input | Type | Default | Bounds/Options | Purpose |
| --- | --- | --- | --- | --- |
| `seed` | Text | `1001` | Non-empty string | Root deterministic input for session, reroll, shop, item, and stat-roll keys. |
| `contractDepth` | Integer | `1` | `1` to `12` for initial lab controls | Simulates run depth for rarity curves and depth-linked value readouts without inspecting route or enemy pressure. |
| `shopSize` | Integer | `4` | `1` to `12` | Number of offers in the current generated shop. |
| `rarityMode` | Enum | `curve` | `curve` or `manual` | Chooses whether rarity odds come from the selected depth curve or editable manual weights. |
| `rarityCurvePreset` | Enum | `early` | `early`, `mid`, `late`, `highVariance` | Applies named candidate rarity curves for fast comparison. |
| `rarityWeights` | Weight map | See initial manual weights below | Basic/Master/Epic/Cursed/Chaos/Unique, each `0` to `100` | Manual procedural rarity odds when `rarityMode` is `manual`. |
| `slotWeights` | Weight map | Equal-ish five-slot spread | Weapon/Helm/Armor/Trinket/Charm, each `0` to `100` | Controls universal slot frequency. |
| `valueScale` | Float | `1.00` | `0.25` to `3.00`, step `0.05` | Manual multiplier after rarity scaling and before/read alongside the contract-depth value hook. |
| `rerollCostBase` | Integer | `5` | `0` to `100` | First reroll cost in gold; kept as a session-feel input, not final P5M7 economy. |
| `rerollCostStep` | Integer | `5` | `0` to `100` | Additional gold cost per reroll; default preserves the old `+5g` pattern. |
| `startingGold` | Integer | `80` | `0` to `9999` | Optional affordability/session pressure readout for feel testing. |
| `batchSize` | Integer | `1000` | `1` to `10000` | Number of shops for aggregate simulation. |

Initial direct controls:

- Show direct fields for `seed`, `contractDepth`, `shopSize`, `valueScale`,
  `batchSize`, `startingGold`, `rerollCostBase`, and `rerollCostStep`.
- Show `rarityMode` as a segmented/manual toggle. In `curve` mode, use preset
  buttons or a select for `rarityCurvePreset`; in `manual` mode, expose sliders
  for procedural rarity weights.
- Show slot odds as five sliders for Weapon, Helm, Armor, Trinket, and Charm.
- Defer full per-stat weight editing unless T3-T8 lands cleanly and there is
  room to add an advanced tuning section. Stat weights should still be visible
  in item metadata and aggregate readouts.

Initial candidate rarity curves:

| Preset | Depth Intent | Basic | Master | Epic | Cursed | Chaos | Unique |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| `early` | Contracts 1-3 | 58 | 26 | 10 | 4 | 1 | 1 |
| `mid` | Contracts 4-7 | 34 | 30 | 20 | 8 | 4 | 4 |
| `late` | Contracts 8-12 | 18 | 25 | 28 | 12 | 8 | 9 |
| `highVariance` | Stress Cursed/Chaos/Unique visibility | 22 | 18 | 20 | 16 | 14 | 10 |

Manual rarity weight defaults should match the `early` preset. These are
candidate lab values only; P5M7 owns the first live Adventure handoff proposal
after simulation evidence exists.

Initial slot weights:

| Slot | Rogue Family | Weight |
| --- | --- | ---: |
| Weapon | Dagger | 20 |
| Helm | Hood | 20 |
| Armor | Doublet | 20 |
| Trinket | Ring | 20 |
| Charm | Necklace | 20 |

Deterministic seed and key behavior:

- Treat `seed` as a stable string, not only a number, so named tuning seeds can
  be reused.
- A session starts from `sessionKey = seed`.
- A shop roll uses `shopKey = seed|depth:<contractDepth>|shop:<shopIndex>|reroll:<rerollCount>|mode:<rarityMode>|preset:<rarityCurvePreset>`.
- Each item uses `itemKey = shopKey|item:<itemIndex>`.
- Rarity, slot, Chaos outcome, stat selection, and stat value rolls should use
  derived keys such as `itemKey|rarity`, `itemKey|slot`, and
  `itemKey|stat:<rollIndex>|<purpose>`.
- Generated item IDs should be stable and readable:
  `gear.generated.shop_lab.<hash-or-safe-seed>.<shopIndex>.<itemIndex>`.
- Item signatures should include rarity, slot, canonical stat IDs, categories,
  drawback flags, Special flags, rounded values, and roll order. Batch summaries
  should derive from these signatures so repeated settings produce identical
  readouts.
- Changing any visible input that affects generation must produce a distinct
  deterministic output path. Changing presentation-only toggles must not.

Required output metadata per item:

- Item id, deterministic key, source seed, source context, shop index, reroll
  count, item index, contract depth, and value scale.
- Rarity and whether the rarity is procedural, fixed-boundary, or excluded.
- Universal slot and Rogue item family.
- Display name generated from the same Phase 5 family/stat vocabulary used by
  the simulation.
- Price or provisional price if retained for session feel, clearly marked as
  lab-only.
- For each roll: roll index, roll purpose, stat id, label, category, pool
  weight, value kind, raw range, rarity multiplier, depth/value multiplier,
  rounded value, positive/drawback/Special marker, and Chaos outcome type when
  relevant.
- Item-level flags for Cursed, Chaos, Unique, has drawback, has Special, has
  Chance for Retrigger, and Legendary/Crude/Lucky Coin boundary visibility.

Aggregate readouts enabled by this model:

- Rarity frequency, slot frequency, stat category frequency, individual stat ID
  frequency, drawback frequency, Special frequency, Unique Special frequency,
  and Chance for Retrigger appearance/value frequency.
- Cursed readouts: positive count, Rare count, drawback count, drawback stat
  distribution, and positive-versus-drawback magnitude summary.
- Chaos readouts: all-positive, mixed, all-drawback rates, Basic/Rare/drawback
  outcome distribution, and stat collision rejection visibility if any future
  tuning creates impossible pools.
- Depth/value readouts: effective rarity weights by depth/preset and visible
  value-scale multiplier effects on generated stat ranges.

T2 scope boundaries:

- T2 does not port the generator into JavaScript; that is P5M6-T3.
- T2 does not implement deterministic rolling; that is P5M6-T4.
- T2 does not choose final P5M7 live rarity odds, shop prices, gold economy, or
  item scoring.
- T2 does not add final player-facing item-card presentation; T7 provides
  tuning-facing readability and P5M8 owns final UI.
- T2 does not procedurally roll Crude, Lucky Coin, compatibility gear, or
  Legendary stat packages.

Downstream implementation notes:

- T3 should replace the old `gearSlots`, `gearTiers`, `gearAffixDefinitions`,
  `legendaryGearItems`, and Cursed-specific value tables with Phase 5 catalog
  data organized around this input model.
- T4 should make repeatability tests assert that identical input objects produce
  identical offer arrays, item IDs/signatures, and aggregate summaries.
- T5/T6 should use `contractDepth`, `rarityCurvePreset`, and `valueScale`
  without treating the candidate values as final Adventure tuning.
- T8-T10 should consume the required item metadata directly rather than
  recalculating category, Special, drawback, Chaos, or retrigger meaning from
  display labels.

## P5M6-T3 Phase 5 Browser Gear Model Notes

Completed 2026-09-04.

Implemented the first Phase 5 Shop Lab generator port:

- Replaced the old `tools/shop-lab/app.js` three-slot model with five universal
  slots: Weapon, Helm, Armor, Trinket, and Charm.
- Added Rogue family labels for generated offers: Dagger, Hood, Doublet, Ring,
  and Necklace.
- Replaced the old Basic/Master/Cursed/Legendary procedural tier set with the
  active P5M5 procedural rarities: Basic, Master, Epic, Cursed, Chaos, and
  Unique.
- Added catalog-style browser data for canonical Phase 5 stat IDs, stat labels,
  Basic/Rare/Special categories, value kinds, drawback eligibility, slot pools,
  documented pool weights, and slot/stat value ranges.
- Added Phase 5 rarity multipliers and roll shapes:
  Basic rolls 1 Basic stat; Master rolls 2 Basic stats; Epic rolls 3 Basic
  stats and 1 Rare stat; Cursed rolls 2 Basic stats, 1 Rare stat, and 1 Basic
  drawback; Chaos rolls 5 Basic/Rare/drawback outcomes; Unique rolls 3 Basic
  stats, 1 Rare stat, and 1 Special.
- Generated non-Chaos items prevent duplicate stat IDs on the same item,
  including positive/drawback/Special collisions. Chaos intentionally allows
  duplicates across its five outcomes.
- Cursed and Chaos drawbacks now derive from slot-eligible Basic stat pools.
- Unique Specials now roll as fixed binary Special effects from slot-eligible
  Special pools.
- Generated item metadata now includes deterministic keys, source seed/context,
  shop/reroll/item indices, contract depth, value scale, rarity, slot, Rogue
  family, roll categories, pool weights, value kinds, raw ranges, rarity
  multipliers, rounded values, drawback/Special markers, Chaos outcome labels,
  item signatures, and retrigger watch flags.
- Crude, Lucky Coin, compatibility gear, and Legendary stat packages are not in
  procedural offer pools. The lab shows them only as fixed-boundary labels.
- Updated `tools/shop-lab/index.html` so the page presents as a Project Enigma
  Phase 5 gear simulation surface and exposes the T2 controls needed by the new
  model.
- Updated `tools/shop-lab/styles.css` for Helm/Armor slots, Epic/Chaos/Unique
  rarities, tuning metadata, boundary labels, Special rolls, drawbacks, and
  item signatures.
- Updated `tools/shop-lab/README.md` to remove the quarantine language and
  describe the active Phase 5 Shop Lab scope.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- A stale-assumption scan of `tools/shop-lab` found no remaining Phase 4,
  DawnBringer, old `affix.*`, old poison/armor/physical affix, or old
  `legendaryGearItems` procedural-generation matches. Remaining `legendary`
  matches are boundary labels/styles only.

Known T3 limits:

- Contract-depth rarity curves and contract-depth value scaling controls are
  visible, but deeper curve/value readouts remain P5M6-T5 and P5M6-T6.
- Aggregate distribution is now broad enough for repeated-roll tuning; later
  tasks added dedicated Cursed/Chaos and retrigger-risk dashboards.
- The browser model mirrors Phase 5 data by hand for now; P5M6-T12 still owns
  any parity/export check against Godot-side catalog data.

## P5M6-T4 Deterministic Offer Rolling Notes

Completed 2026-09-04.

Implemented and validated deterministic browser offer rolling:

- Added centralized key construction in `tools/shop-lab/app.js` through
  `deterministicKeys()`, `shopKey()`, `chaosOutcomeKey()`,
  `statSelectionKey()`, and `statValueKey()`.
- The root `seed` remains a stable string input so numeric and named tuning
  seeds can both be reused.
- Shop keys now include seed, contract depth, shop index, reroll count, rarity
  mode, rarity preset, and a hash of generation-affecting settings.
- Item keys derive from the shop key and item index.
- Rarity rolls, slot rolls, Chaos outcome rolls, stat-selection rolls, and
  stat-value rolls derive from explicit key paths.
- Generated item IDs remain stable as
  `gear.generated.shop_lab.<safe-seed>.<shopIndex>.<itemIndex>`.
- Item signatures include rarity, slot, canonical stat IDs, categories,
  positive/drawback/Special markers, rounded values, and Chaos outcome labels.
- Added scriptable snapshot helpers for offers and batch summaries:
  `normalizedOfferSnapshot()`, `batchSummarySnapshot()`, and
  `deterministicSelfCheck()`.
- Exposed a small `ShopLabTesting`/CommonJS testing API from `app.js` so the
  static browser tool can still be checked from Node.
- Added `tools/shop-lab/determinism_check.js`, which stubs the minimal browser
  DOM, loads the Shop Lab script, and asserts deterministic behavior.

Verified behavior:

- Same seed/settings produce identical normalized shop offers.
- Same seed/settings produce identical batch summaries.
- Reroll path changes produce a distinct but reproducible offer set.
- Contract-depth changes affect the deterministic output path.
- Value-scale changes affect generated roll values and item signatures.
- Procedural generation still excludes Crude, Lucky Coin, compatibility gear,
  and Legendary stat packages.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/determinism_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- A stale-assumption scan of `tools/shop-lab` found no active Phase 4,
  DawnBringer, old `affix.*`, old poison/armor/physical affix, old `gearTiers`,
  old `baseTypes`, or old `legendaryGearItems` matches.

Handoff:

- P5M6-T5 can build rarity-curve behavior on top of the existing preset/manual
  rarity weight inputs and deterministic key paths.
- P5M6-T6 can make contract-depth value scaling visible without changing the
  key contract again.
- P5M6-T8 through P5M6-T10 can use normalized item signatures and roll metadata
  for richer aggregate, Cursed/Chaos, Unique Special, and retrigger-risk
  readouts.

## P5M6-T5 Contract-Depth Rarity Curve Notes

Completed 2026-09-04.

Implemented candidate contract-depth rarity curves in Shop Lab:

- Added depth-aware rarity curve anchors for `early`, `mid`, `late`, and
  `highVariance`.
- `effectiveRarityWeights()` now interpolates the selected curve from contract
  depth 1 through 12 when `rarityMode` is `curve`.
- Manual rarity mode continues to use the explicit manual slider weights and
  does not change rarity odds by contract depth.
- Interpolated curve weights are normalized back to a 100-point total so the
  readouts and weighted picker stay easy to reason about.
- Added `rarityProbabilityRows()` for configured/observed rarity readout data.
- Added a visible `curve-readout` panel under Rarity Odds showing the effective
  weight and probability for each procedural rarity at the current depth and
  selected curve.
- Batch simulation output now includes the current rarity mode, curve preset,
  contract depth, configured rarity odds, and observed rarity odds.
- `tools/shop-lab/README.md` now describes depth-aware rarity curve presets.

Initial curve behavior:

| Preset | Depth 1 Emphasis | Depth 12 Emphasis |
| --- | --- | --- |
| `early` | Strong Basic/Master bias with nearly no Chaos. | Still conservative, but Epic/Cursed/Unique become more visible. |
| `mid` | Moderate Basic/Master bias with low advanced rarity presence. | Epic becomes common and Cursed/Unique are meaningfully visible. |
| `late` | Starts closer to mid-run distribution. | Strong Epic/Unique/Cursed presence with some Chaos. |
| `highVariance` | Elevated Cursed/Chaos/Unique for stress testing. | Very high Chaos/Cursed/Unique visibility for risk tuning. |

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/curve_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.

Known T5 limits:

- These curve anchors are lab candidates only. P5M7 owns the first live
  Adventure rarity handoff after more simulation evidence exists.
- Broad aggregate rarity/stat distribution views are now covered by P5M6-T8;
  dedicated Cursed/Chaos and retrigger interpretation remains P5M6-T9/T10.

## P5M6-T6 Contract-Depth Value Scaling Notes

Completed 2026-09-04.

Implemented candidate contract-depth value scaling in Shop Lab:

- `contractDepthValueScale(contractDepth)` now returns a conservative depth
  multiplier from `1.00x` at contract depth 1 to `1.35x` at contract depth 12.
- Manual `valueScale` remains a separate input so rarity frequency and item
  magnitude can be tuned independently.
- Generated roll metadata continues to record raw range, rarity multiplier,
  depth multiplier, manual value scale, rounded value, value kind, category,
  drawback flag, and Special flag.
- Added `combinedValueScale()`, `valueScaleRows()`, and `summarizeRollValues()`
  helpers for UI and scripted checks.
- Added a visible value readout under Run Setup showing manual multiplier,
  depth multiplier, combined multiplier, and example effective stat ranges.
- Batch simulation output now reports the value input line and average positive
  and drawback magnitude.
- `batchSummarySnapshot()` now includes manual value scale, depth value scale,
  combined value scale, and value-summary data for scripted comparison.
- `tools/shop-lab/README.md` now notes that manual and contract-depth value
  scaling are separated.

Initial value-scaling model:

| Contract Depth | Depth Multiplier |
| ---: | ---: |
| 1 | `1.00x` |
| 12 | `1.35x` |

Intermediate depths interpolate linearly across the same 1-12 contract-depth
range used by rarity curves. These values are Shop Lab candidates only and do
not change Godot-side generator behavior or live Adventure economy tuning.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/value_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.
- `node tools/shop-lab/value_check.js` passed with
  `value ok: depth 1.00x->1.35x, combined 1.50x`.

Known T6 limits:

- The depth multiplier is a lab candidate, not a final P5M7 Adventure value.
- Godot-side `GearGenerator._contract_depth_value_scale()` remains neutral
  until a later integration/tuning task chooses to adopt a live value curve.
- Richer per-rarity, per-category, and per-stat value interpretation remains
  P5M6-T9+ tuning scope.

## P5M6-T7 Generated Item Readability Notes

Completed 2026-09-04.

Improved Shop Lab item cards for tuning-facing readability:

- Offer cards now read first as rarity, Rogue family, and universal slot.
- Added card badges for rarity, slot, Rogue family, Chaos, Unique, drawback,
  Special, and Chance for Retrigger watch cases.
- Grouped rolls into `Positive Stats`, `Drawbacks`, `Specials`, and `Invalid`
  sections so high-risk and Unique items scan without reading raw metadata.
- Primary roll text now favors formatted values and labels, such as
  `+18% Percent Physical Damage` or `Enemies can no longer dodge`.
- Secondary roll metadata remains visible in compact rows for stat ID,
  category, pool weight, raw range, rarity multiplier, manual value scale,
  depth multiplier, and Chaos outcome when relevant.
- Item signatures remain visible for deterministic comparison and tuning
  discussion.
- Fixed boundary labels remain separate from generated item cards: Crude,
  Lucky Coin, compatibility gear, and Legendary catalog items are not mixed
  into procedural offers.
- `tools/shop-lab/README.md` now records the grouped card/readability scope.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/readability_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.
- `node tools/shop-lab/value_check.js` passed with
  `value ok: depth 1.00x->1.35x, combined 1.50x`.
- `node tools/shop-lab/readability_check.js` passed with
  `readability ok: 30 rarity/slot cards`.

Known T7 limits:

- This remains a Shop Lab tuning card, not final P5M8 player-facing item UI.
- Dedicated Cursed/Chaos and retrigger-risk dashboards are now covered by
  P5M6-T9 and P5M6-T10.

## P5M6-T8 Distribution And Frequency Readout Notes

Completed 2026-09-04.

Implemented broad session and batch aggregate readouts:

- Added `aggregateItems()` as the shared aggregation path for session UI,
  batch summaries, and scriptable checks.
- Aggregate buckets now cover item count, roll count, rarity, slot, roll
  marker, stat category, stat ID, drawback stat ID, Special stat ID, Unique
  Special stat ID, Chaos outcome, Cursed shape, retrigger values, value
  magnitudes, item signatures, and broad quality bands.
- The Distribution panel now shows compact bar groups for rarity, slot, roll
  markers, categories, and Chaos outcomes.
- The Distribution panel now shows top lists for stat IDs, drawback stat IDs,
  and Special stat IDs from the current session.
- Quick Sim output now reports configured versus observed rarity odds,
  observed slot odds, roll marker mix, category mix, top stats, drawback stats,
  Special stats, Unique Special rate, Chaos outcome mix, Cursed shape, broad
  quality bands, average positive/drawback magnitude, retrigger appearances,
  top rarity, and top slot.
- `batchSummarySnapshot()` now returns the same aggregate buckets for tests and
  later tuning scripts.
- `tools/shop-lab/README.md` now records the expanded distribution/frequency
  scope.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/distribution_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.
- `node tools/shop-lab/value_check.js` passed with
  `value ok: depth 1.00x->1.35x, combined 1.50x`.
- `node tools/shop-lab/readability_check.js` passed with
  `readability ok: 30 rarity/slot cards`.
- `node tools/shop-lab/distribution_check.js` passed with
  `distribution ok: 640 items, 2382 rolls, 28 stat buckets`.

Known T8 limits:

- Chance for Retrigger is counted broadly here; P5M6-T10 adds the dedicated
  cap-risk/build-risk watch.
- The quality bands are rough lab signals only, not final item balance or
  player-facing scoring.

## P5M6-T9 Cursed And Chaos Tuning View Notes

Completed 2026-09-04.

Implemented dedicated risk-rarity tuning views:

- Added `summarizeCursedItems()` to calculate Cursed item count/rate, valid
  shape count/rate, positive roll count, drawback roll count, average positive
  magnitude, average drawback magnitude, top positive stats, and top drawback
  stats.
- Added Cursed shape validation in the summary: each Cursed item should have
  exactly 2 Basic positive rolls, 1 Rare positive roll, and 1 Basic drawback.
- Added `summarizeChaosItems()` to calculate Chaos item count/rate, positive
  and drawback roll counts, outcome counts, average positive/drawback
  magnitude, top positive stats, and top drawback stats.
- Added `chaosClassification()` so Chaos items are classified as
  `all_positive`, `mixed`, or `all_drawback`.
- The Distribution panel now includes compact `Cursed View` and `Chaos View`
  sections alongside the broad T8 aggregate readouts.
- Quick Sim output now reports Cursed balance, Chaos classification rates, and
  Chaos balance in addition to the broad distribution lines.
- `batchSummarySnapshot()` now exposes `cursedSummary` and `chaosSummary` for
  tests and later tuning scripts.
- `tools/shop-lab/README.md` now records the dedicated Cursed/Chaos tuning
  view scope.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/cursed_chaos_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.
- `node tools/shop-lab/value_check.js` passed with
  `value ok: depth 1.00x->1.35x, combined 1.50x`.
- `node tools/shop-lab/readability_check.js` passed with
  `readability ok: 30 rarity/slot cards`.
- `node tools/shop-lab/distribution_check.js` passed with
  `distribution ok: 640 items, 2382 rolls, 28 stat buckets`.
- `node tools/shop-lab/cursed_chaos_check.js` passed with
  `risk ok: 400 cursed valid, chaos 146/1050/4`.

Known T9 limits:

- These views expose risk/reward shape but do not finalize Cursed or Chaos
  balance.
- Rare-stat drawbacks remain deferred; current Cursed/Chaos drawbacks still use
  Basic-stat drawback pools.

## P5M6-T10 Retrigger Risk Visibility Notes

Completed 2026-09-04.

Implemented Chance for Retrigger risk visibility:

- Added `summarizeRetriggerRisk()` to calculate retrigger item count/rate,
  roll count, affected shop count, multi-retrigger shop count, slot mix, rarity
  mix, min/average/max rolled values, top-five stack total, cap proximity, and
  sorted retrigger values.
- The Distribution panel now includes a compact `Retrigger Watch` section.
- Quick Sim output now includes a `Retrigger watch` summary line alongside the
  broader T8/T9 aggregate readouts.
- The cap-risk approximation uses the top five retrigger values from a batch as
  a repeated-offer/build-risk signal, then clamps cap proximity at 100%.
- The summary remains visibility-only: it does not change combat retrigger
  behavior, stat caps, recursive retrigger limits, or live Adventure tuning.
- `tools/shop-lab/README.md` now records the Retrigger Watch scope.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/retrigger_check.js` passed.
- `node tools/shop-lab/determinism_check.js` passed with
  `determinism ok: 4 offers, 256 batch items`.
- `node tools/shop-lab/curve_check.js` passed with
  `curve ok: late depth Basic 32->12, Unique 5->12`.
- `node tools/shop-lab/value_check.js` passed with
  `value ok: depth 1.00x->1.35x, combined 1.50x`.
- `node tools/shop-lab/readability_check.js` passed with
  `readability ok: 30 rarity/slot cards`.
- `node tools/shop-lab/distribution_check.js` passed with
  `distribution ok: 640 items, 2382 rolls, 28 stat buckets`.
- `node tools/shop-lab/cursed_chaos_check.js` passed with
  `risk ok: 400 cursed valid, chaos 146/1050/4`.
- `node tools/shop-lab/retrigger_check.js` passed with
  `retrigger ok: 444 items, top5 180%, multi shops 132`.

Known T10 limits:

- Top-five stacking is a lab approximation for repeated-offer/build-risk
  visibility, not a legal equipped-build validator.
- Full combat pacing validation for recursive retriggers remains P5M11 scope.
- Final live rarity/value curves that affect retrigger frequency remain P5M7
  handoff decisions.

## P5M6-T11 Quick Simulation Preset Notes

Completed 2026-09-04.

Implemented repeatable quick simulation presets:

- Added `quickSimulationPresets` as the shared preset source for browser UI and
  scriptable checks.
- Added four presets:
  - `Early Run`: depth 2, Early curve, 0.95x manual value, 4-item shops, 400
    batch shops, `early-run` seed.
  - `Mid Run`: depth 6, Mid curve, 1.00x manual value, 4-item shops, 700 batch
    shops, `mid-run` seed.
  - `Late Run`: depth 10, Late curve, 1.08x manual value, 5-item shops, 1,000
    batch shops, `late-run` seed.
  - `High Variance`: depth 12, High Variance curve, 1.15x manual value, 5-item
    shops, 1,200 batch shops, `high-variance` seed.
- Added a `Quick Preset` selector and preset readout to Run Setup so screenshots
  and tuning notes identify the active comparison setup.
- Applying a preset syncs the visible controls, regenerates the shop, and keeps
  batch simulation output deterministic from the preset seed/settings.
- Manual control edits move the setup back to `Custom` so changed screenshots
  are not mislabeled as preset runs.
- `tools/shop-lab/README.md` now records the Quick Simulation preset scope.
- Added `tools/shop-lab/preset_check.js` to verify preset values, effective
  curve weights, deterministic batch snapshots, item counts, and unknown-preset
  fallback behavior.

Verification:

- `node --check tools/shop-lab/app.js` passed.
- `node --check tools/shop-lab/preset_check.js` passed.
- `node tools/shop-lab/preset_check.js` passed with
  `presets ok: earlyRun, midRun, lateRun, highVariance`.

Known T11 limits:

- Presets are lab comparison shortcuts, not final P5M7 Adventure economy
  commitments.
- Preset seeds are named for repeatability and screenshot comparison; they are
  not live run seed rules.

## P5M6-T12 Focused Regression Check Notes

Completed 2026-09-05.

Consolidated the Shop Lab regression surface:

- Added `tools/shop-lab/run_checks.js` as the one-command regression runner for
  Shop Lab syntax and behavior checks.
- Exported the small testing-facing catalog identifiers needed by the checks:
  procedural rarities, universal slots, and Rogue family labels.
- Added `tools/shop-lab/phase5_shape_check.js` to verify the Phase 5 browser
  model keeps exactly five slots, five Rogue families, and six procedural
  rarities: Basic, Master, Epic, Cursed, Chaos, and Unique.
- The Phase 5 shape check also verifies generated batches exercise Weapon,
  Helm, Armor, Trinket, Charm, Dagger, Hood, Doublet, Ring, Necklace, and all
  procedural rarities without generating Crude, Lucky Coin, compatibility gear,
  or Legendary stat packages.
- Added `tools/shop-lab/stale_assumption_check.js` to scan the active Shop Lab
  files for old Phase 4/DawnBringer presentation language, old affix ids, the
  retired three-slot array, old amazing-score language, and procedural
  Legendary/Crude rarity returns while allowing intentional fixed-boundary
  labels.
- Added `tools/shop-lab/random_seed_check.js` coverage to the one-command
  runner so the Random seed toggle remains covered alongside deterministic
  generation.
- Updated `tools/shop-lab/curve_check.js` to lock the current Early curve Chaos
  visibility checkpoints at depths 1, 6, and 12.
- Kept the existing deterministic, curve, value, readability, distribution,
  Cursed/Chaos, retrigger, and preset checks in the runner.

Verification:

- `node tools/shop-lab/run_checks.js` passed with
  `shop-lab checks ok: 23 checks passed`.
- Included behavior outputs:
  - `determinism ok: 4 offers, 256 batch items`
  - `curve ok: late depth Basic 32->12, Unique 5->12`
  - `value ok: depth 1.00x->1.35x, combined 1.50x`
  - `readability ok: 30 rarity/slot cards`
  - `distribution ok: 640 items, 2382 rolls, 28 stat buckets`
  - `risk ok: 400 cursed valid, chaos 146/1050/4`
  - `retrigger ok: 444 items, top5 180%, multi shops 132`
  - `presets ok: earlyRun, midRun, lateRun, highVariance`
  - `random seed ok: 8 variants`
  - `phase5 shape ok: 5 slots, 6 rarities, 5 Rogue families`
  - `stale assumptions ok: scanned 3 files`

Known T12 limits:

- The checks validate the browser Shop Lab model and its intended Phase 5
  boundaries; live Adventure reward/shop wiring remains P5M7.
- The stale-assumption scan is intentionally narrow to `tools/shop-lab`
  active files and is not a whole-repository migration audit.
- Godot-side `StatCatalog`/`GearGenerator` parity remains structurally mirrored
  rather than fully code-generated from one shared source.

## P5M6-T13 Docs And Closeout Notes

Completed 2026-09-05.

P5M6 is complete. Shop Lab has been rebuilt from the quarantined Phase 4
browser tool into the active Phase 5 gear-economy tuning surface. It now rolls
five-slot Rogue gear, exposes deterministic shop sessions, simulates
contract-depth rarity and value scaling, shows item-level readability evidence,
and summarizes distributions for Cursed, Chaos, Unique, Special, drawback, and
Chance for Retrigger risk.

Current working Shop Lab baseline for P5M7 discussion:

| Input | Current Value | Notes |
| --- | --- | --- |
| Seed | `1001` | Manual deterministic default; Random mode can create a fresh visible seed per generated session. |
| Contract depth | `1` to `12` | Used by lab rarity curves and value scaling. |
| Shop size | `4` | Quick presets use `4` or `5` depending on scenario. |
| Slot odds | Weapon 20%, Helm 20%, Armor 20%, Trinket 20%, Charm 20% | Equal five-slot starting point. |
| Value scale | Manual `1.00x`; depth scale `1.00x` at depth 1 to `1.35x` at depth 12 | Candidate tuning only; Godot live generator remains neutral until integration chooses a value curve. |
| Rarity mode | Early curve | Default conservative curve with Chaos made visible enough for tuning. |
| Procedural rarities | Basic, Master, Epic, Cursed, Chaos, Unique | Crude, Lucky Coin, compatibility gear, and Legendary stat packages stay fixed-boundary exclusions. |

Current default Early curve checkpoints:

| Depth | Basic | Master | Epic | Cursed | Chaos | Unique |
| ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 65% | 23% | 6% | 2% | 3% | 1% |
| 6 | 54% | 26% | 10% | 4% | 4% | 2% |
| 12 | 41% | 29% | 15% | 7% | 5% | 3% |

P5M7 handoff proposal:

- Start live reward/shop integration from the completed P5M5 Godot generator
  and use Shop Lab as the comparison surface for expected item shapes.
- Preserve deterministic seed paths for generated rewards and
  between-contract shop offers so runs remain reproducible.
- Use five-slot procedural offers: Weapon, Helm, Armor, Trinket, and Charm,
  displaying Rogue families as Dagger, Hood, Doublet, Ring, and Necklace.
- Preserve fixed boundaries: Crude remains starter-only, Lucky Coin remains a
  fixed Tavern Trinket/Ring reward, compatibility gear stays out of normal
  procedural pools, and Legendary items use fixed catalog paths rather than
  procedural stat packages.
- Treat the current Early rarity curve and depth value scaling as the first
  live integration candidate, not final balance.
- Keep Chaos visible during integration testing so its power and drawback mix
  can be judged from real shop/reward contexts rather than only batch stats.
- Keep Unique Specials Unique-only for the first P5M7 pass unless live
  integration immediately shows Special frequency is too low or too dominant.
- Keep Cursed/Chaos drawbacks Basic-stat-only for the first P5M7 pass; revisit
  Rare-stat drawbacks only if the risk/reward readouts feel too mild.
- Continue watching Chance for Retrigger, especially multi-item shops and
  repeated-offer stack estimates, because legal-build validation remains P5M11.

Closeout verification:

- `node tools/shop-lab/run_checks.js` passed with
  `shop-lab checks ok: 23 checks passed`.

Remaining ownership:

- P5M7 owns live Adventure reward/shop wiring and the first in-game rarity,
  value, gold, and deterministic-offer handoff.
- P5M8 owns final player-facing item presentation.
- P5M9 completed Hood/Doublet art and broader generated Rogue item-art cleanup.
- P5M10 owns retained Legendary stat packages and final Legendary tuning.
- P5M11 owns broad Practice Room and Balance Lab validation.

## Current Known Decisions

- P5M6 owns Shop Lab simulation and tuning visibility, not final live Adventure
  reward/shop integration.
- The pre-P5M6 browser Shop Lab was quarantined as a Phase 4 tool. The current
  lab now runs the Phase 5 generator model in browser form, with final
  Adventure economy integration still deferred to P5M7.
- P5M6 does not require new visual gear assets. Tool-facing rarity colors,
  badges, labels, tables, and simple slot symbols are enough for this milestone.
- P5M6 should expose tuning/debug information that final player-facing item UI
  may hide later.
- P5M8 owns final inventory/equipment UI and item-card presentation.
- P5M9 completed Hood and Doublet sprites and broader generated Rogue item-art
  cleanup.
- P5M10 owns retained Rogue Legendary stat package updates and final Legendary
  value tuning.
- P5M11 owns broad Practice Room and Balance Lab validation after shop, reward,
  presentation, art, and Legendary milestones land.
- Random shop simulation must remain deterministic from visible seed/settings.
- Shop Lab should not inspect upcoming route or enemy pressure directly when
  rolling gear. It can simulate contract depth and tuning curves.
- Shop Lab implementation should use the T2 input model as its public
  simulation contract: visible generation-affecting inputs must be represented
  in deterministic keys, and presentation-only toggles must not change rolls.
- Crude remains starter-only and should not appear as a procedural shop offer.
- Lucky Coin remains a fixed Tavern reward and should not appear in simulated
  procedural shop pools.
- Legendary items remain fixed-catalog items. P5M6 may show Legendary boundary
  information, but it should not procedurally roll Legendary stat packages.
- Special stats are currently Unique-only. P5M6 should inspect whether that
  frequency feels right before later milestones decide whether to change it.
- Drawbacks are currently Basic-stat-only. P5M6 should help decide whether
  Rare-stat drawbacks are needed later.
- Chance for Retrigger is a watch item because chance stats cap at 100% and
  recursive retriggers have combat pacing risk.

## Open Implementation Questions

- The current bridge decision is hybrid: Shop Lab keeps a browser-side Phase 5
  generator mirror for fast simulation while Godot remains the live integration
  source. A fully shared data-export path remains optional future tooling.
- What item scoring/readability heuristic, if any, should the lab use for
  "exciting" or "risky" offers without pretending to solve final balance?

## Completion Notes

P5M6 is complete.

P5M6-T1 completed the current Shop Lab audit on 2026-09-04. No implementation
changes or test runs were required for the audit-only task.

P5M6-T2 completed the Shop Lab simulation input model on 2026-09-04. No
implementation changes or test runs were required for the documentation-only
task.

P5M6-T3 ported the Phase 5 procedural gear model into the browser Shop Lab on
2026-09-04. `node --check tools/shop-lab/app.js` passed, and the stale
Phase 4/old-affix/procedural-Legendary scan found only intended Legendary
boundary labels/styles.

P5M6-T4 implemented deterministic offer rolling on 2026-09-04. Syntax checks
passed for `app.js` and `determinism_check.js`, and the deterministic assertion
script passed for repeated offers, batch summaries, reroll variation,
contract-depth variation, and value-scale variation.

P5M6-T5 implemented contract-depth rarity curves on 2026-09-04. Syntax,
determinism, and curve behavior checks passed; curve mode now interpolates
rarity odds by depth while manual mode preserves explicit rarity weights.

P5M6-T6 implemented contract-depth value scaling visibility on 2026-09-04.
Syntax, determinism, curve, and value behavior checks passed; Shop Lab now
separates manual value scale from depth value scale and shows their combined
effect on generated stat ranges and batch summaries.

P5M6-T7 improved generated item readability on 2026-09-04. Syntax,
determinism, curve, value, and readability checks passed, including forced
render-oriented coverage for every procedural rarity and universal slot pair.

P5M6-T8 added distribution and frequency readouts on 2026-09-04. Syntax,
determinism, curve, value, readability, and distribution reconciliation checks
passed, including a fixed high-variance batch with 640 items, 2,382 rolls, and
28 stat buckets.

P5M6-T9 added dedicated Cursed and Chaos tuning views on 2026-09-04. Syntax,
determinism, curve, value, readability, distribution, and risk-rarity checks
passed, including forced Cursed shape validation and Chaos all-positive, mixed,
and all-drawback classification coverage.

P5M6-T10 added Retrigger Watch visibility on 2026-09-04. Syntax,
determinism, curve, value, readability, distribution, risk-rarity, and
retrigger checks passed, including forced retrigger-eligible batches that
exercise multi-retrigger shops and top-five cap-proximity reporting.

P5M6-T11 added Quick Simulation presets on 2026-09-04. Syntax and preset
behavior checks passed, including Early Run, Mid Run, Late Run, and High
Variance setup application, effective curve verification, deterministic batch
snapshots, and Custom fallback behavior.

P5M6-T12 added focused Shop Lab regression checks on 2026-09-05. The
one-command runner `node tools/shop-lab/run_checks.js` passed with 23 checks,
including syntax, deterministic generation, curve/value behavior, readability,
distribution, Cursed/Chaos views, retrigger visibility, presets, random seed
behavior, Phase 5 slot/rarity/family shape, fixed-boundary exclusions, and
stale Phase 4 assumption removal.

P5M6-T13 closed out Shop Lab gear simulation on 2026-09-05. This tracker,
`docs/P5_Gear_Redesign_Overview.md`, `docs/New_Gear_Overview.md`, and
`docs/Project_Onboarding_Context.md` now record P5M6 as complete, preserve the
current Shop Lab tuning baseline, and hand P5M7 the first live
reward/shop-integration candidate values and caveats. Final verification passed
with `node tools/shop-lab/run_checks.js` reporting
`shop-lab checks ok: 23 checks passed`.
