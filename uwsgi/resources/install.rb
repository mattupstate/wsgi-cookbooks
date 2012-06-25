
actions :install

attribute :virtualenv, :kind_of => String, :default => nil

def initialize(*args)
  super
  @action = :install
end