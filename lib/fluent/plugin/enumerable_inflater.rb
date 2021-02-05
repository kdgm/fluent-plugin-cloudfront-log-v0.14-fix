# frozen_string_literal: true
require 'zlib'

class EnumerableInflater

  CHUNKSIZE = 1024**2

  def initialize(options = {})
    @io = options[:io]
  end

  def lines
    Enumerator.new { |main_enum| stream_lines(main_enum) }
  end

  private

  attr_reader :io, :inflater

  def stream_lines(main_enum)
    init_gzip_inflater

    split_lines.lazy.each { |line| main_enum << line }
  ensure
    inflater&.close
  end

  def split_lines
    buffer = ""

    Enumerator.new do |yielder|
      ungzip.each do |decompressed_chunk|
        buffer += decompressed_chunk
        new_buffer = ""
        buffer.each_line do |l|
          l.end_with?("\n") ? yielder << l : new_buffer += l
        end

        buffer = new_buffer
      end
    end
  end

  def ungzip
    Enumerator.new do |yielder|
      stream_file.each do |compressed|
        inflater.inflate(compressed) do |decompressed_chunk|
          yielder << decompressed_chunk
        end
      end
    end
  end

  def stream_file
    Enumerator.new do |stream_enum|
      io.each(nil, CHUNKSIZE) do |chunk|
        stream_enum << chunk
      end
    end
  end

  def init_gzip_inflater
    # Taken from examples in:
    # https://docs.ruby-lang.org/en/2.0.0/Zlib/Inflate.html
    @inflater = Zlib::Inflate.new(Zlib::MAX_WBITS + 32)
  end

end
