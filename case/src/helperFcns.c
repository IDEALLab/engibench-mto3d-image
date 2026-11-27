
scalar normL2(volScalarField x){
  scalar a=0;
  forAll(x,i) {
    a+=pow(x[i],2);
  }
  return std::sqrt(a);
}


// scalar simple_continuation(scalar q_, label q_cont_dir_, scalar q_init_, scalar q_step_, scalar limit_, scalar f_c_, label opt_){
    
//     if (q_cont_dir_ == 0) {return q_;}
//     if (opt_ < f_c_) {return q_;}

//     if (q_cont_dir_ == 1)//increasing and compare with the minimum of the limit_!
//     {
//         q_ = q_init_ + (opt_-f_c_)*q_step_;
//         q_ = Foam::min(q_,limit_);
//     }
    
//     if (q_cont_dir_ == -1)//decreasing and compare with the maximum of the limit_!
//     {
//         q_ = q_init_ - (opt_-f_c_)*q_step_;
//         q_ = Foam::max(q_,limit_);
//     }

//     return q_;
// }

// scalar fromListContinuation(scalar q_, List<scalar> q_list_, label every_, label opt_, label& curr_pos_)
// {
//     if (q_ == q_list_[q_list_.size()-1]) {return q_;}//we reached maximum
//     auto mod = opt_ % every_;//haven't reached a point to change the q!
//     if (mod != 0) {return q_;}
//     return q_list_[++curr_pos_];
// }

// void readContinuationParams(dictionary inputDict, List<scalar>& list, label& nSteps){
// Info << "reading continuation paramters for: " << endl << inputDict.name() << endl;
// word type = word(inputDict.lookup("type"));

// if(type == "automatic_VL")
// {
//   Info << "Continuation is automatic (variable slope logarithmic scale), with following specifications:" << endl;
//   scalar lower(readScalar(inputDict.lookup("lower")));
//   scalar upper(readScalar(inputDict.lookup("upper")));
//   scalar slope(readScalar(inputDict.lookup("slope")));
//   Info << "lower bound: " << lower << endl;
//   Info << "upper bound: " << upper << endl;
//   Info << "nonlinear logarithmic slope: " << slope << endl;
//   nSteps = readLabel(inputDict.lookup("nSteps"));
//   list=automaticContinuation(lower,upper,slope,nSteps);
// }
// if(type == "fromList")
// {
//   Info << "Continuation is fromList with following specifications:" << endl;
//   nSteps = readLabel(inputDict.lookup("nSteps"));
//   list = List<scalar>(inputDict.lookup("list"));
// }
// else
// {
//   error("undefined type of continuation, choose from automatic_VL(variable slope logarithmic, lower,upper,slope,nSteps)|fromList(list(),nSteps)");
// }
// Info << "number of continuation steps: " << nSteps << endl;
// Info << "the continuation list values:" << list << endl;
// }
