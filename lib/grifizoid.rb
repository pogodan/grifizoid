class Grifizoid
  def initialize(app, &path_blk)
    @app            = app
    @path_blk       = path_blk
  end
  
  # Get file from GridFileSystem or pass-thru
  def call(env)
    begin
      gfs_path = extract_gfs_path(env)
      file = Mongo::GridFileSystem.new(Mongoid.database).open(gfs_path, 'r')
      etag, last_modified = file.instance_variable_get(:@md5), Time.at( file.upload_date.to_i )
      
      headers = {
        'ETag' => "\"#{etag}\"",
        'Last-Modified' => last_modified.httpdate,
      }
      if not_modified?(env, etag, last_modified )
        [304, headers, 'Not Modified']
      else
        [200, headers.merge('Content-Type' => file.content_type, 'Content-Length' => file.file_length.to_s), file]
      end
    rescue Mongo::GridError, Mongo::GridFileNotFound
      @app.call(env)
    end
  end
  
  # use raw path or path request to block to let user set a custom path
  def extract_gfs_path(env)
    request   = Rack::Request.new(env)
    
    if @path_blk
      @path_blk.call(request)
    else
      request.path_info
    end
  end

  private
  def not_modified?(env, etag, last_modified )
    if_none_match = env['HTTP_IF_NONE_MATCH']
    if if_modified_since = env['HTTP_IF_MODIFIED_SINCE']
      if_modified_since = Time.rfc2822(if_modified_since) rescue nil
    end
    
    not_modified = if_none_match.present? || if_modified_since.present?
    not_modified &&= (if_none_match == "\"#{etag}\"")       if if_none_match && etag
    not_modified &&= (if_modified_since >= last_modified)   if if_modified_since && last_modified
    not_modified
  end
end