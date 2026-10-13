# Feature brick

Generates domain entities and repository contracts, source models, a data source,
repository implementation, Cubit/state, page/view, exports, and behavior tests.

```sh
./tool/make_feature.sh inventory
```

The wrapper reads the package name from `pubspec.yaml`, rejects invalid names and
existing feature paths, then formats the generated files. Route and dependency
registration stay explicit in the composition root; instructions are generated
inside the feature README. No hooks or automatic global source edits are used.

Validate the actual rendered template with `./tool/check_feature_template.sh`.
