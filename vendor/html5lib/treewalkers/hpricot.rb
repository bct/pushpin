require 'html5lib/treewalkers/base'
require 'rexml/document'

module HTML5lib
  module TreeWalkers
    module Hpricot
      class TreeWalker < HTML5lib::TreeWalkers::NonRecursiveTreeWalker

        def node_details(node)
          case node
          when ::Hpricot::Elem
            if node.name.empty?
              [:DOCUMENT_FRAGMENT]
            else
              [:ELEMENT, node.name,
                node.attributes.map {|name,value| [name,value]},
                !node.empty?]
            end
          when ::Hpricot::Text
            [:TEXT, node.to_plain_text]
          when ::Hpricot::Comment
            [:COMMENT, node.content]
          when ::Hpricot::Doc
            [:DOCUMENT]
          when ::Hpricot::DocType
            [:DOCTYPE, node.target]
          when ::Hpricot::XMLDecl
            [nil]
          else
            [:UNKNOWN, node.class.inspect]
          end
        end

        def first_child(node)
          node.children.first
        end

        def next_sibling(node)
          node.next_node
        end

        def parent(node)
          node.parent
        end
      end
    end
  end
end
