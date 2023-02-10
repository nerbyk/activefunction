## [Unreleased]

## [0.1.0] - 2022-12-28

- Add `before_action` and `after_action` callbacks with `:only` and `:if` options
- Add `ActiveFunction::Base#params` with `require`, `permit`, `[]` and `to_h` public methods
- Add specs for `ActiveFunction::Base.params` module
- Add `ActiveFunction::Base#render` with `:status`, `:json` and `:head` options
- Add RBS signature
- Add RBS Aws Event Types
- Add public interface type `steep` checking
- Add `ruby-next` transpiler

## [0.2.0] - 2023-01-08

- Add unit tests
- Fix Steep pipeline & add better RBS type signatures 
- Refactor `::Functions` module
- Add `Response` class

## [0.3.0] - 2023-01-12

- cleanup
- add ActiveFunction::Functions::Response#commit!
- extract action processing to separate method to handle ActiveFunction::Functions::Callbacks#process overriding
- add test for ActiveFunction::Base.process


# [0.3.1] - 2023-02-09

- Updated readme
- Make callbacks inheritable
- `include` -> `prepend` Core module

# [0.3.2] - 2023-02-10

- Finish readme
- Fix callbacks broken by `prepend` change
- Add more tests for `#process` public interface
