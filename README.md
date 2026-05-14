# CF_SRAM_16384x32 — vyges-ip mirror

Mirror of [chipfoundry/CF_SRAM_16384x32](https://github.com/chipfoundry/CF_SRAM_16384x32) — a pre-hardened commercial SRAM macro for sky130A.

| | |
|---|---|
| Upstream | `chipfoundry/CF_SRAM_16384x32` |
| Pinned release | `CF_SRAM_16384x32-v1.0.1` |
| License | Apache-2.0 (per upstream) |
| Mirror type | `vendor_drop` (whole-repo verbatim, LFS for `.gds`) |
| Sync schedule | Weekly + on `upstream.yaml` change + manual dispatch |

## Consumers

soc-generator's `vendor_ips.py` resolves this mirror by version tag for any soc-spec.yaml that declares a matching `vendor_macros[]` entry. Downstream:

```bash
git clone --branch CF_SRAM_16384x32-v1.0.1 https://github.com/vyges-ip/cf-sram-16384x32 <target>/ip/CF_SRAM_16384x32
```

## How to bump the pinned release

1. Edit `upstream.yaml` → `upstream.version`
2. Push — the sync workflow runs automatically and pulls the new tag.

See [`upstream.yaml` schema](https://github.com/vyges/vyges-ip-internal/blob/main/upstream/upstream-yaml.schema.json) for the full field reference.
