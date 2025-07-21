# features/support/hooks.rb
Before do |scenario|
  taglist = scenario.respond_to?(:source_tag_names) ?
              scenario.source_tag_names :
              scenario.tags.map(&:name)

  if taglist.include?('@javascript')
    DatabaseCleaner.strategy = :truncation
  else
    DatabaseCleaner.strategy = :transaction
  end

  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end