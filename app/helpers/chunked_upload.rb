class ChunkedUpload
  attr_accessor :upload

  #def self.sanitize(filename)
    #filename.gsub(/[[:space:]]/, '_')
  #end

  def initialize(upload)
    #@upload, @finished, @progress_size, @total_size = upload, false, 0, 0
    @upload = upload
    FileUtils.mkdir_p(upload.store_dir)
  end

  #def attributes
    #{
      #finished: finished,
      #chunk_id: id,
      #progress: progress_size / total_size.to_d * 100
      #progress_size: progress_size,
      ##@progress = @progress_size / params[:total_size].to_d * 100
      #total_size: total_size
    #}
  #end

  #def id
    #return @id if @id

    #if upload.chunk_id
      ## TODO: properly handle resuming existing chunked uploads
      #@id = upload.chunk_id
    #else
      #@id = SecureRandom.hex
      #upload.update(chunk_id: @id)
    #end
  #end

  #def ext
    #return @ext if @ext

    #unless upload.chunk_ext
      #upload.update(chunk_ext: File.extname(chunk.original_filename))
    #end
  #end

  def build_upload(params)
    upload.update(
      total_size: params[:total_size].to_i,
      ext: ext_from(params[:data].content_type)
    )
  end

  def store_chunk(params)
    chunk = params[:data]
    unless upload.persisted?
      return unless build_upload(params)
    end

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

  def ext_from(content_type)
    case content_type
    when %r{audio/(mp3|mp4)}
      $1
    end
  end

  def cleanup_part_files
    file_part_names = Dir.glob("#{upload.file_dir}.part.*")

    file_part_names.each do |part_name|
      File.delete(part_name)
    end
  end

  #def resource_dir
    #"#{upload.class.to_s.underscore}/#{upload.id}"
  #end

  #def store_dir(filename = nil)
    #dir = "#{Rails.root.to_path}/public/chunked_uploads/#{resource_dir}"
    #"#{dir}/#{filename}" if filename || dir
  #end

  def current_chunk_number
    total_chunks = Dir.glob("#{upload.file_dir}.part.*").map do |path|
      File.extname(path)[1..-1].to_i
    end
    most_recent = total_chunks.sort.last || -1
    most_recent + 1
  end

  #def valid_params(params)
    #params[:chunk_data] && params[:total_size]
  #end
end
