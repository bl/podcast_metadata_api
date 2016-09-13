class ChunkedUpload
  attr_reader :resource
  attr_accessor :finished, :id, :progress

  def self.sanitize(filename)
    filename.gsub(/[[:space:]]/, '_')
  end

  def initialize(resource)
    @resource, @finished, @progress = resource, false, 0
    FileUtils.mkdir_p(store_dir)
  end

  def attributes
    {
      finished: finished,
      chunk_id: id,
      progress: progress,
    }
  end

  # TODO generate a key to use for each (store_chunk) (SecureRandom.uuid filename maybe?)
  def store_chunk(params)
    chunk = params[:chunk_data]
    ext = File.extname(chunk.original_filename)
    set_id(ext)
    chunk_filename = "#{id}.part.#{current_chunk_number}"
    FileUtils.copy(chunk.tempfile.path, store_dir(chunk_filename))

    File.open(store_dir(id), 'ab') do |result_file|
      while buffer = chunk.tempfile.read(4096)
        result_file.write buffer
      end

      # TODO: have sanity checking locally
      if result_file.size == params[:total_size].to_i
        file_part_names = Dir.glob("#{store_dir(id)}.part.*").sort

        # cleanup part files
        file_part_names.each do |part_name|
          File.delete(part_name)
        end

        self.finished = true
      end

      @progress = result_file.size / params[:total_size].to_d * 100
    end
    # TODO: handle deleting files on failure/background job to cleanup after timeout
  end

  def read(&block)
    File.open(store_dir(id), 'r') do |final_file|
      yield final_file
    end
  end

  def cleanup
    @resource.update(chunk_id: nil)
    File.delete(store_dir(id))
  end

  private

  def set_id(ext)
    if @resource.chunk_id
      # TODO: properly handle resuming existing chunked uploads
      @id = @resource.chunk_id
    else
      @id = SecureRandom.hex + ext
      @resource.update(chunk_id: @id)
    end
  end

  def resource_dir
    "#{resource.class.to_s.underscore}/#{resource.id}"
  end

  def store_dir(filename = nil)
    dir = "#{Rails.root.to_path}/public/chunked_uploads/#{resource_dir}"
    "#{dir}/#{filename}" if filename || dir
  end

  def current_chunk_number
    total_chunks = Dir.glob("#{store_dir(id)}.part.*").map do |path|
      File.extname(path)[1..-1].to_i
    end
    most_recent = total_chunks.sort.last || -1
    most_recent + 1
  end
end
