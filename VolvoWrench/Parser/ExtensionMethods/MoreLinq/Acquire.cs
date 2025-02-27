#region License and Terms

// MoreLINQ - Extensions to LINQ to Objects
// Copyright (c) 2012 Atif Aziz. All rights reserved.
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
//     http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#endregion

using System;
using System.Collections.Generic;

namespace VolvoWrench.ExtensionMethods.MoreLinq
{
    public static partial class MoreEnumerable
    {
        /// <summary>
        ///     Ensures that a source sequence of <see cref="IDisposable" />
        ///     objects are all acquired successfully. If the acquisition of any
        ///     one <see cref="IDisposable" /> fails then those successfully
        ///     acquired till that point are disposed.
        /// </summary>
        /// <typeparam name="TSource">Type of elements in <paramref name="source" /> sequence.</typeparam>
        /// <param name="source">Source sequence of <see cref="IDisposable" /> objects.</param>
        /// <returns>
        ///     Returns an array of all the acquired <see cref="IDisposable" />
        ///     object and in source order.
        /// </returns>
        /// <remarks>
        ///     This operator executes immediately.
        /// </remarks>
        public static TSource[] Acquire<TSource>(this IEnumerable<TSource> source)
            where TSource : IDisposable
        {
            if (source == null) throw new ArgumentNullException("source");

            var disposables = new List<TSource>();
            try
            {
                disposables.AddRange(source);
                return disposables.ToArray();
            }
            catch
            {
                foreach (var disposable in disposables) disposable.Dispose();

                throw;
            }
        }
    }
}