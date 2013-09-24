module SD
	class Dust
		attr_accessor :content, :content_type, :id, :rect
		def initialize(content, content_type)
			self.content      = content
			self.content_type = content_type
		end
		def draw(rect)
			self.rect = self.content_type.draw(rect, self)
		end
		def size(rect = nil)
			SD::Rect.new self.content_type.size(rect, content)
		end
		def context
			SD::Context.current
		end

		module Text
			def self.size(rect, content)
				SD::Context.current.bitmap.text_size content
			end
			def self.draw(rect, dust)
				SD::Context.current.bitmap.draw_text rect.original_rect, dust.content
				rect
			end
		end
		module ShadowedText
			def self.size(rect,content)
				rect=::Rect.new(0,0,rect.width,rect.height)
				bmp=Bitmap.new(1,1)
				srect=bmp.text_size(to_ss(content))
				#if SD::Context.current.shadow
				srect.width+=1
				srect.height+=1
				#end
				bmp.dispose
				::Rect.new(x=[rect.x,srect.x].max,y=[rect.y,srect.y].max,[rect.width,srect.width].min-x,[rect.height,srect.height].min-y)
			end
			def self.draw(rect,dust)
				bmp=Bitmap.new( (srect=self.size(rect,str=to_ss(dust.content))).width,srect.height )
				bmp.font=(bitmap= SD::Context.current.bitmap ).font
				bmp.draw_text(srect,str)
				x=(align=self.align(dust.content))==0 ? rect.x : align==2 ? rect.x+rect.width-srect.width : rect.x+(rect.width-srect.width)/2
				y= rect.y+(rect.height-srect.height)/2 
				bitmap.blt(x,y,bmp,srect)
				bmp.dispose
				srect
			end
			def self.align(content)
				if content.is_a?(Hash)
					if align=content[:align]
						return align
					end
				end
				SD::Context.current.align 
			rescue
				0
			end
			def self.to_ss(content)
				case content
				when Hash
					content[:text]
				when String
					content
				else
					raise TypeError
				end
			end
		end
		module Picture
			def self.size(rect,content)
				bmp=get_bmp(content)
				srect=bmp.rect
				rect=Rect.new(0,0,rect.width,rect.height)
				Rect.new(x=[rect.x,srect.x].max,y=[rect.y,srect.y].max,[rect.width,srect.width].min-x,[rect.height,srect.height].min-y) 
			end
			def self.draw(rect,dust)
				bmp=get_bmp(dust.content)
				align=align(dust.content)
				srect=(ss=self.size(rect,dust.content)).original_rect

				bitmap=SD::Context.current.bitmap
				case align
				when 0
					bitmap.stretch_blt(rect,bmp,srect)#���ֺͲ��������ˡ���
				when 1..9
					x = ss.dup
					x.pin align, rect, align
					bitmap.blt(x.x, x.y, bmp, srect)
				end
				Rect.new(x.x, x.y, srect.width, srect.height)
			end
			def self.align(content)
				if content.is_a?(Hash)
					if align=content[:align]
						return align
					end
				end
				SD::Context.current.align 
			rescue
				5
			end 
			def self.get_bmp(content)
				Bitmap.new content[:src]
			end
		end


	end
end