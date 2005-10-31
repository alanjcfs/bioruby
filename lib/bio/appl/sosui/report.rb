#
# = bio/appl/sosui/report.rb - SOSUI report class
# 
# Copyright::   Copyright (C) 2003 Mitsuteru C. Nakao <n@bioruby.org>
# Licence::     LGPL
#
#  $Id: report.rb,v 1.8 2005/10/31 17:01:50 nakao Exp $
#
# == Example
#
# == References
# * http://sosui.proteome.bio.tuat.ac.jp/sosui_submit.html
#--
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#++
#


module Bio

  class SOSUI

    # = SOSUI output report parsing class
    #
    # == References
    # * http://sosui.proteome.bio.tuat.ac.jp/sosui_submit.html
    class Report

      # Delimiter
      DELIMITER = "\n>"
      RS = DELIMITER

      # Query entry_id
      attr_reader :entry_id

      # Returns the prediction result whether "MEMBRANE PROTEIN" or 
      # "SOLUBLE PROTEIN".
      attr_reader :prediction

      # Transmembrane helixes ary
      attr_reader :tmhs

      # Parser for SOSUI output report.
      def initialize(output_report)
        entry       = output_report.split(/\n/)

        @entry_id   = entry[0].strip.sub(/^>/,'')
        @prediction = entry[1].strip
        @tms        = 0
        @tmhs       = []
        parse_tmh(entry) if /MEMBRANE/ =~ @prediction
      end

      private

      # Parser for TMH lines.
      def parse_tmh(entry)
        entry.each do |line|
          if /NUMBER OF TM HELIX = (\d+)/ =~ line
            @tms = $1
          elsif /TM (\d+) +(\d+)- *(\d+) (\w+) +(\w+)/ =~ line
            tmh  = $1.to_i
            range = Range.new($2.to_i, $3.to_i)
            grade = $4
            seq   = $5
            @tmhs.push(TMH.new(range, grade, seq))
          end
        end
      end


      # = Bio::SOSUI::Report::TMH
      # Container class for transmembrane helix information.
      #  
      #  TM 1   31-  53 SECONDARY   HIRMTFLRKVYSILSLQVLLTTV
      class TMH

        # Returns aRng of transmembrane helix
        attr_reader :range
        
        # Retruns ``PRIMARY'' or ``SECONDARY'' of helix.
        attr_reader :grade

        # Returns the sequence. of transmembrane helix. 
        attr_reader :sequence

        # Sets values.
        def initialize(range, grade, sequence)
          @range = range
          @grade = grade
          @sequence = sequence
        end
      end

    end # class Report

  end # class SOSUI

end # module Bio



if __FILE__ == $0

  begin
    require 'pp'
    alias p pp 
  rescue LoadError
  end


  sample = <<HOGE
>HOGE1
 MEMBRANE PROTEIN
 NUMBER OF TM HELIX = 6
 TM 1   12-  34 SECONDARY   LLVPILLPEKCYDQLFVQWDLLH
 TM 2   36-  58 PRIMARY     PCLKILLSKGLGLGIVAGSLLVK
 TM 3  102- 124 SECONDARY   SWGEALFLMLQTITICFLVMHYR
 TM 4  126- 148 PRIMARY     QTVKGVAFLACYGLVLLVLLSPL
 TM 5  152- 174 SECONDARY   TVVTLLQASNVPAVVVGRLLQAA
 TM 6  214- 236 SECONDARY   AGTFVVSSLCNGLIAAQLLFYWN

>HOGE2
 SOLUBLE PROTEIN

HOGE

  def hoge(ent)
    puts '==='
    puts ent
    puts '==='
    sosui = Bio::SOSUI::Report.new(ent)
    p [:entry_id, sosui.entry_id]
    p [:prediction, sosui.prediction]
    p [:tmhs.size, sosui.tmhs]
    pp [:tmhs, sosui.tmh]
  end

  sample.split(/#{Bio::SOSUI::Report::DELIMITER}/).each {|ent|
    hoge(ent)
  }

  exit if ARGV.size == 0

  while ent = $<.gets(Bio::SOSUI::Report::DELIMITER)
    hoge(ent)
  end

end



