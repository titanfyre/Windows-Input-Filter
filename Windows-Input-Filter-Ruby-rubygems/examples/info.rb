require 'windows_input_filter'
WindowsInputFilter::Interceptor.open { |client| p client.info }
