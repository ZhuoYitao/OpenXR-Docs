# Copyright (c) 2020 The Khronos Group Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This file customizes the way that asciidoctor-pdf makes the index,
# so it's not all uselessly sorted under "X" since all the terms start with "XR"

# see https://github.com/asciidoctor/asciidoctor-pdf#how-index-terms-are-grouped-and-sorted

require 'asciidoctor-pdf'

# Normalizes an OpenXR entity name to just the part that matters for ordering.
def strip_prefix(name)
  name.sub /^[xX][rR](_?)/, ""
end

module Asciidoctor::PDF
  # Override how the "Category" (first letter heading) is computed
  # Docs and source for original version:
  # https://www.rubydoc.info/github/asciidoctor/asciidoctor-pdf/Asciidoctor/Pdf/IndexCatalog#store_primary_term-instance_method
  IndexCatalog.prepend(
    ::Module.new do
      def store_primary_term(name, dest = nil)
        store_dest dest if dest
        # After stripping the prefix (if any) do a multibyte-uppercase
        # and grab the first character as the category
        category = uppercase_mb(strip_prefix(name)).chr
        (init_category category).store_term name, dest
      end
    end
  )

  # Override how index terms are sorted: they ignore their prefix.
  # Docs and source for original version:
  # https://www.rubydoc.info/github/asciidoctor/asciidoctor-pdf/Asciidoctor/Pdf/IndexTermGroup#%3C=%3E-instance_method
  IndexTermGroup.prepend (
      ::Module.new do
        def <=>(other)
          this = strip_prefix(@name)
          that = strip_prefix(other.name)
          (val = this.casecmp that) == 0 ? this <=> that : val
        end
      end)
end
