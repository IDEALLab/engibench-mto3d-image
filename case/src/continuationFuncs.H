template<typename T>
List<T> linspace(T start_in, T end_in, label num_in)
{

  List<T> linspaced(num_in,end_in);

  if (num_in == 1) 
    {
      return linspaced;
    }

  T delta = (end_in - start_in) / (num_in - 1);

  for(label i=0; i < num_in-1; ++i)
    {
      linspaced[i]=start_in + delta * i;
    }
  // linspaced.push_back(end_in); // I want to ensure that start and end
                            // are exactly the same as the input
  return linspaced;
}


template<typename T>
List<T> geomspace(T first, T last, label size)
{

  List<T> linspaced(size);

  if (size == 1) 
    {
      linspaced[0]=last;
      return linspaced;
    }
  
  bool rev=false;
  if(first>last) {
      std::swap(first,last);
      rev=true;
  }
  T expfirst = std::exp(first);
  T explast = std::exp(last);
  T step = (explast-expfirst)/(size-1);
  int i=0;
  for(T x=expfirst; x<=explast; x+=step)
  {
    T a = std::log(x);
    linspaced[i++]=a;
  }
  linspaced[size-1]=last;
  if (rev) {std::reverse(linspaced.begin(),linspaced.end());}
  return linspaced;
  
}

// template<typename T>
// void printVector(std::vector<T> V){
//     for (auto i: V)
//     std::cout << i << ' ';
//     std::cout << endl;
// }

template<typename T>
List<T> automaticContinuation(T lower,T upper,T a, label n){
    if(upper==lower){List<T> temp0(n,lower);return temp0;}
    List<T> temp0 = linspace(std::log(lower)*a,std::log(upper)*a,n);
    for (int i=0;i < n;i++){
        temp0[i]=std::exp(temp0[i]);
    }
    T max = Foam::max(temp0);
    T min = Foam::min(temp0);
    // Info << max << endl;
    // Info << min << endl;
    for (int i=0;i < n;i++){
        temp0[i]=temp0[i]/max-min/max;
    }
    for (int i=0;i < n;i++){
        temp0[i]=temp0[i]*(upper-lower)+lower;
    }
    // printVector(temp0);
    temp0[0]=lower;temp0[n-1]=upper;
    if(upper<lower){
        std::sort(temp0.begin(), temp0.end(), std::greater<T>());
    }
    return temp0;
    // auto temp = exp(linspace(log(lower)*a,log(upper)*a,n));
}

List<scalar> linSpace_1(scalar start, scalar end, label n)
{
  List<scalar> v(n,start);
  n=n-1;
  scalar delta = (end-start)/((scalar )n) ;
  for (label s=1;s<n;s++){
    v[s]=start+delta*((scalar) s);
  }
  v[n]=end;
  return v;
}

List<scalar> geomSpace_1(scalar start, scalar end, label n)
{
  List<scalar> v(n,start);
  n=n-1;
  for (label s=1;s<n;s++){
    v[s]=start*std::pow((end/start),((scalar) s/(scalar )n));
  }
  v[n]=end;
  return v;
}

void createContinuationList(word type, scalar from,scalar to, List<scalar>& list, label n_levels){
  if (type == "constant"){
    list=List<scalar>(n_levels,from);
  }
  if (from == to) {
    list=List<scalar>(n_levels,from);
  }
  if (type == "linear"){
    list=linSpace_1(from,to,n_levels);
  }
  if (type == "geometric"){
    list=geomSpace_1(from,to,n_levels);
  }
}




