# <img src="https://github.com/FeatherTools/.github/blob/main/profile/feather-logo-200.png" alt="FeatherTools Logo" width="100" height="100"> Core gRPC Contracts

[![NuGet](https://img.shields.io/nuget/v/Feather.Contracts.svg)](https://www.nuget.org/packages/Feather.Contracts)
[![NuGet Downloads](https://img.shields.io/nuget/dt/Feather.Contracts.svg)](https://www.nuget.org/packages/Feather.Contracts)
[![.NET Tests](https://github.com/FeatherTools/grpc.contract.core/actions/workflows/net-tests.yaml/badge.svg)](https://github.com/FeatherTools/grpc.contract.core/actions/workflows/net-tests.yaml)

> Core Protobuf contracts (generic, reusable message types) shared across Feather gRPC services — packaged for both .NET and PHP.

This repository is the single source of truth for the low-level, domain-agnostic contracts used across Feather. The Protobuf schema in [`proto/feather/contracts/core/v1/core.proto`](proto/feather/contracts/core/v1/core.proto) is compiled into:

- a **.NET** library published as the [`Feather.Contracts`](https://www.nuget.org/packages/Feather.Contracts) NuGet package,
- a **PHP** package (`feather/contracts`) with generated message, client and RoadRunner server classes under [`gen/php/`](gen/php/), and
- a **Protobuf module** published to the [Buf Schema Registry](https://buf.build/feathertools/contracts) (`buf.build/feathertools/contracts`).

It is designed to be consumed in three ways:

1. As a **.NET dependency** in the `Feather.Grpc` library, providing the core message types.
2. As a **PHP dependency** in the PHP contracts library, providing the same core types.
3. **Directly in other `.proto` files**, by depending on the BSR module `buf.build/feathertools/contracts` and referencing the `feather.contracts.core.v1` types.

## Contracts

All messages live in the `feather.contracts.core.v1` package ([`proto/feather/contracts/core/v1/core.proto`](proto/feather/contracts/core/v1/core.proto)):

| Message                 | Purpose                                                                        |
| ----------------------- | ------------------------------------------------------------------------------ |
| `Error`                 | Structured error with a `name` and `message`.                                  |
| `CorrelationId`         | Request/trace correlation identifier.                                          |
| `Timestamp`             | Unix timestamp in milliseconds.                                                |
| `Spot`                  | A `zone` + `bucket` location pair.                                             |
| `Instance`              | A single instance identifier.                                                  |
| `Box`                   | An `Instance` bound to a `Spot`.                                               |
| `SerializedForChunking` | Wrapper (`bytes content`) for chunking large payloads in streaming gRPC calls. |

Generated namespaces (derived by Buf managed mode from the `feather.contracts.core.v1` package):

- .NET: `Feather.Contracts.Core.V1`
- PHP: `Feather\Contracts\Core\V1` (messages) and `Feather\Contracts\Core\V1\GPBMetadata` (metadata)

## Install

### .NET

```sh
dotnet add package Feather.Contracts
```

```fsharp
open Feather.Contracts.Core.V1

let error = Error(Name = "NotFound", Message = "Instance not found")
```

### PHP

Not published to Packagist — consume it as a git VCS repository. Add the repository to your `composer.json`:

```json
{
    "repositories": [
        {
            "type": "vcs",
            "url": "https://github.com/FeatherTools/grpc.contract.core.git"
        }
    ]
}
```

Then require it (use the tag/branch you need):

```sh
composer require feather/contracts:dev-main
```

```php
use Feather\Contracts\Core\V1\Error;

$error = (new Error())->setName('NotFound')->setMessage('Instance not found');
```

### Import in another `.proto`

Add the BSR module as a dependency in your `buf.yaml`:

```yaml
version: v2
deps:
  - buf.build/feathertools/contracts
```

Then import and reference the `feather.contracts.core.v1` types:

```proto
syntax = "proto3";

import "feather/contracts/core/v1/core.proto";

message Envelope {
  feather.contracts.core.v1.CorrelationId correlation_id = 1;
  feather.contracts.core.v1.Error         error          = 2;
}
```

## Local development

```sh
dotnet tool restore
dotnet tool run paket install
./build.sh
composer install
```

### Build targets

The build is driven by [FAKE](https://fake.build/) via [`build.sh`](build.sh):

```sh
./build.sh                    # default target
./build.sh -t tests no-lint   # run tests
./build.sh -t publish no-lint # pack & publish the NuGet package
```

Common flags: `no-lint`, `no-clean` to skip the respective steps.

## Working with the Protobuf schema

[`proto/feather/contracts/core/v1/core.proto`](proto/feather/contracts/core/v1/core.proto) is the source of truth. After editing it:

1. **Lint** the schema:

   ```sh
   buf lint
   ```

2. **.NET** and **PHP** classes are regenerated with Buf using the remote plugins in [`buf.gen.yaml`](buf.gen.yaml):

   ```sh
   buf generate
   ```

   This produces C# under [`gen/csharp/`](gen/csharp/) (namespace `Feather.Contracts.Core.V1`, compiled by [`Contracts.csproj`](Contracts.csproj)) and PHP message, client and RoadRunner server classes under [`gen/php/`](gen/php/) (namespace `Feather\Contracts\Core\V1`); both are committed to the repository. `buf build` only compiles the schema to an in-memory image; use `buf generate` to emit code.

   > **Before opening a PR**, run `buf generate` and commit the regenerated `gen/` files so they stay in sync with the schema in git.

3. **Publish** the module to the Buf Schema Registry:

   ```sh
   buf registry login   # first time only
   buf push             # publishes buf.build/feathertools/contracts
   ```

### Proto conventions

- File name: `lower_snake_case`; messages: `UpperCamelCase`; fields: `lower_snake_case`; enum values: `UPPER_SNAKE_CASE`.
- Keep types generic and domain-agnostic — this library holds only reusable primitives.
- Enforced by Buf's `STANDARD` lint rule set (see [`buf.yaml`](buf.yaml)).

## Repository layout

```
proto/feather/contracts/core/v1/core.proto   # Source-of-truth Protobuf schema
buf.yaml                                     # Buf module (buf.build/feathertools/contracts), lint & breaking config
buf.gen.yaml                                 # Buf code generation (managed mode, remote plugins)
Contracts.csproj                             # .NET package (Feather.Contracts), compiles gen/csharp
composer.json                                # PHP package (feather/contracts), autoloads gen/php
gen/csharp/                                  # Generated C# classes (committed, compiled by Contracts.csproj)
gen/php/                                     # Generated PHP classes (committed, autoloaded by composer)
build/                                       # FAKE build project (F#)
.github/workflows/                           # CI: net-tests, php-tests, proto-lint, net-publish, bsr-publish, pr-check
```

## Releasing

Publishing the NuGet package is triggered by pushing a semver tag (`MAJOR.MINOR.PATCH`), which runs the [`.NET Publish`](.github/workflows/net-publish.yaml) workflow. Update [`CHANGELOG.md`](CHANGELOG.md) and the `<Version>` in [`Contracts.csproj`](Contracts.csproj) before tagging. Publish the Protobuf module to the BSR with `buf push`.
