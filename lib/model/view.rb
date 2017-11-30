require "mustache"

class Mustache::Parser
  # ['{', '=', '&', '>', '<'] removed
  VALID_TYPES = [ '#', '^', '/', '!' ].map(&:freeze)
end

class BasicView < Mustache
  alias_method :mustacheEscapeHTML, :escapeHTML

  def escapeHTML(string)
    raise NotImplementedError "A View should implement explicit escaping behaviour."
  end
end

class View < BasicView
  def escapeHTML(string)
    string
  end
end

class HTMLEscapedView < BasicView
  def escapeHTML(string)
    mustacheEscapeHTML(string)
  end
end
