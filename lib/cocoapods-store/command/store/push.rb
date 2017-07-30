require 'aws-sdk'

module Pod
  class Command
		class Store < Command

			class Push < Store

				self.summary = 'Stores cocoapods installation data for quicker installation'

				self.description = <<-DESC
					Stores cocoapods installation data for quicker installation
				DESC


				# Accessors

				def commit
					return `git show --pretty=%H`
				end

				# Plugin Lifecycle

				def initialize(argv)
					super
				end

				def validate!
					super
				end

				def run

					verify_podfile_exists!
					verify_lockfile_exists!

					archive_cache
					push_cache
				end

				# Run steps

				def archive_cache

					@cache_dir = "#{Dir.pwd}/#{cache_dir_name}"

					UI.puts "Creating cache directory: #{@cache_dir}"

					FileUtils.rm_rf @cache_dir
					FileUtils.mkdir_p @cache_dir

					# Copy files to the cache folder
					begin
						FileUtils.cp_r "#{Dir.pwd}/Pods", @cache_dir
						FileUtils.cp_r Dir.glob("#{Dir.pwd}/*.xcworkspace").first, @cache_dir
						FileUtils.cp_r "#{Dir.pwd}/Podfile.lock", @cache_dir
					rescue RuntimeError => e
						UI.puts "[!] An error occurred - #{e.message}".red
						FileUtils.rm_rf @cache_dir
						exit 1
					end

					# Archive the cache folder
					@zip_name = "#{cache_dir_name}.zip"
					system "ditto -ck --rsrc --sequesterRsrc #{cache_dir_name} #{@zip_name}"
				end

				def push_cache

					begin
						s3 = load_s3_bucket

						obj = s3.bucket('pod-store').object(@zip_name)
						UI.puts "Uploading #{@zip_name}"
						obj.upload_file("#{Dir.pwd}/#{@zip_name}")

						UI.puts "✔︎ Cache uploaded successfully".green.bold

					rescue Aws::Errors::MissingCredentialsError => e
						UI.puts "S3 upload failed: Credentials were not present".red.bold
					rescue Aws::S3::Errors::NoSuchBucket => e
						UI.puts "S3 upload failed: the bucket specified does not exist".red.bold
					rescue Aws::Errors::ServiceError => e
						UI.puts "[!] S3 upload failed: A service error occurred - #{e.message}".red.bold
					ensure
						FileUtils.rm_rf @cache_dir
						FileUtils.rm_rf "#{Dir.pwd}/#{@zip_name}"
					end

				end

			end # class Push

		end # class Store
	end # class Command
end # module Pod
