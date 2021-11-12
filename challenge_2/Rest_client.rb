=begin
code from Mark Wilkinson ( I just refactor
because I don't like call the function as a proper method of ruby, it is confusing for me)
=end

def retrieve(url, headers = {accept: '*/*'}, user = '', pass='') 
  RestClient::Request.execute({
                                           method: :get,
                                           url: url.to_s,
                                           user: user,
                                           password: pass,
                                           headers: headers
                                         })
  

rescue RestClient::ExceptionWithResponse => e
  warn e.inspect
  false
  
rescue RestClient::ExceptionWithResponse => e
  warn e.inspect
  false
  
rescue RestClient::ExceptionWithResponse => e
  warn e.inspect
  false
  
end

