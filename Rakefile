if !ENV["APPRAISAL_INITIALIZED"] && !ENV["TRAVIS"]
  # appraisal is a ruby gem that lets us test our code
  # against multiple dependency sets (gemfiles)
  task :default => :appraisal
end