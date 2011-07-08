require 'ragnar/connector'
require 'ragnar/amqp/exchange'
require 'ragnar/bunny/exchange'

# For development
# require File.expand_path('ragnar/connector', File.dirname(__FILE__))
# require File.expand_path('ragnar/amqp/exchange', File.dirname(__FILE__))
# require File.expand_path('ragnar/bunny/exchange', File.dirname(__FILE__))

module Ragnar

  module_function

  def amqp_exchange type, name, options={}
    exch = exchanges[key('AMQP', type, name)] || store(Ragnar::AMQP::Exchange.new(type, name, options))
    yield(exch) if block_given?
    exch
  end

  def bunny_exchange(type, name, options={})
    exch = exchanges[key('Bunny', type, name)] || store(Ragnar::Bunny::Exchange.new(type, name, options))
    yield(exch) if(block_given?)
    exch
  end

  def store ex
    exchanges[key(ex.class.to_s.split('::')[1], ex.type, ex.name)] = ex
  end

  def exchanges
    @exchanges ||= {}
  end

  def key klass, type, name
    '%s-%s-%s' % [klass, type.to_s, name]
  end

  def publish(routing_key, message, opts={})
    bunny_exchange.publish(routing_key, message, opts={})
  end

  private :store, :exchanges, :key

end
