require_relative '../services/record_service'

desc "Deletes a record"
task :delete_record do

  id = 1063113958
  RecordService.delete(id)
  puts "Deleted record #{id}"

end
