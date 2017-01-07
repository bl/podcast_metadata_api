class ChunkedUpload
  attr_accessor :upload

  def initialize(upload)
    @upload = upload
    FileUtils.mkdir_p(upload.store_dir)
  end

  def validate_chunk(chunk)
    errors = { }
    if @upload.finished?
      add_error(errors, :upload, 'has already been completed')
    end
    if !chunk.present?
      add_error(errors, :chunk, 'is not present')
    elsif !valid_chunk_size(chunk)
      add_error(errors, :chunk, 'is incorrect size. Use provided upload chunk size')
    end

    errors
  end

  def add_error(errors, key, message)
    errors[key] ||= []
    errors[key] << message
  end

  def store_chunk(chunk)
    chunk_filename = "#{upload.filename}.part.#{current_chunk_number}"
    FileUtils.copy(chunk.tempfile.path, upload.store_dir(chunk_filename))

    File.open(upload.file_dir, 'ab') do |result_file|
      while buffer = chunk.tempfile.read(4096)
        result_file.write(buffer)
      end

      if result_file.size == upload.total_size
        cleanup_part_files
      end
    end
    # TODO: handle deleting files on failure/background job to cleanup after timeout
  end

  def read(&block)
    File.open(upload.file_dir, 'r') do |final_file|
      yield final_file
    end
  end

  def cleanup
    cleanup_part_files
    File.delete(upload.file_dir)
    @upload.update(chunk_id: nil)
  end

  private

  def valid_chunk_size(chunk)
    chunk.present? && chunk.size <= upload.chunk_size
  end

  def ext_from(content_type)
    case content_type
    when content_type_mp3
      'mp3'
    end
  end

  def content_type_mp3
    Regexp.union(
      %r{audio/(mpeg|mp3|mpeg3|x-mpeg3)},
      %r{video/(mpeg|x-mpeg)}
    )
  end

  def cleanup_part_files
    file_part_names = Dir.glob("#{upload.file_dir}.part.*")

    file_part_names.each do |part_name|
      File.delete(part_name)
    end
  end

  def current_chunk_number
    total_chunks = Dir.glob("#{upload.file_dir}.part.*").map do |path|
      File.extname(path)[1..-1].to_i
    end
    most_recent = total_chunks.sort.last || -1
    most_recent + 1
  end
end
