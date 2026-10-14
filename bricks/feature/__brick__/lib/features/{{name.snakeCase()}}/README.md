# {{name.titleCase()}}

Register `{{name.pascalCase()}}RepositoryImpl({{name.pascalCase()}}DataSource())` in `AppDependencies`,
expose the contract with `RepositoryProvider<{{name.pascalCase()}}Repository>`, and add
`{{name.pascalCase()}}Page` to the app router. The page owns its Cubit.

The source starts with an empty collection. Replace its implementation with local
storage or the shared API client. Keep infrastructure out of the Cubit. Add domain
use cases when an operation has business rules instead of simple method forwarding.

Move the generated heading and empty-state message into the app localization files
when defining the final feature copy. Tests cover the repository and page behavior.

Use `app_ui` for visual tokens and shared controls. Keep feature-specific
components in `presentation/widgets`; pass values and callbacks to them.
