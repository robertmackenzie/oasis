include Oasis::Model

RSpec.describe BasicView do
  # View enables simple templating. The type of BasicView determines behaviour,
  # rather than the template itself. This enables use cases such as safe user
  # submitted templates, templating of HTTP headers, and an explicit UnsafeView
  # for security testing. For example, View has been used to template mock HTTP
  # services for automated testing, where escaping of the body is determined by
  # the response Content-Type, which is itself a template.

  describe View do
    describe ".render" do
      it "should allow variable tags" do
        variable_tag = "Hi, {{ name }}"
        data = { name: "Rob" }
        view = View.render(variable_tag, data)

        expect(view).to eq "Hi, #{data[:name]}"
      end

      it "should disallow escaped variable tags" do
        variable_tag = "Hi, {{{ name }}}"
        data = { name: "Rob" }

        expect {
          View.render(variable_tag, data)
        }.to raise_error Mustache::Parser::SyntaxError
      end

      it "should disallow the escape ampersand" do
        variable_tag = "Hi, {{& name }}"
        data = { name: "Rob" }

        expect {
          View.render(variable_tag, data)
        }.to raise_error Mustache::Parser::SyntaxError
      end

      it "should NOT HTML escape templates" do
        variable_tag = "<p>Hi, {{ name }}</p>"
        data = { name: "< Rob >" }
        view = View.render(variable_tag, data)

        expect(view).to eq "<p>Hi, #{data[:name]}</p>"
      end
    end
  end

  describe HTMLEscapedView do
    describe ".render" do
      it "should allow variable tags" do
        variable_tag = "Hi, {{ name }}"
        data = { name: "Rob" }
        view = HTMLEscapedView.render(variable_tag, data)

        expect(view).to eq "Hi, #{data[:name]}"
      end

      it "should disallow escaped variable tags" do
        variable_tag = "Hi, {{{ name }}}"
        data = { name: "Rob" }

        expect {
          HTMLEscapedView.render(variable_tag, data)
        }.to raise_error Mustache::Parser::SyntaxError
      end

      it "should disallow the escape ampersand" do
        variable_tag = "Hi, {{& name }}"
        data = { name: "Rob" }

        expect {
          HTMLEscapedView.render(variable_tag, data)
        }.to raise_error Mustache::Parser::SyntaxError
      end

      it "should HTML escape templates" do
        variable_tag = "<p>Hi, {{ name }}</p>"
        data = { name: "< Rob >" }
        view = HTMLEscapedView.render(variable_tag, data)

        expect(view).to eq "<p>Hi, &lt; Rob &gt;</p>"
      end
    end
  end
end
