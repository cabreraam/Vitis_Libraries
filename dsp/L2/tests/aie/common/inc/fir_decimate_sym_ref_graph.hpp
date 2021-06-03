#ifndef _DSPLIB_FIR_DECIMATE_SYM_REF_GRAPH_HPP_
#define _DSPLIB_FIR_DECIMATE_SYM_REF_GRAPH_HPP_

#include <adf.h>
#include <vector>
#include "fir_decimate_sym_ref.hpp"
#include "fir_ref_utils.hpp"

#define CEIL(x, y) (((x + y - 1) / y) * y)
#define INPUT_MARGIN(x, y) CEIL(x, (32 / sizeof(y)))

namespace xf {
namespace dsp {
namespace aie {
namespace fir {
namespace decimate_sym {
using namespace adf;

// The template list here has to match that of the UUT because the L2 flow instances each graph (UUT/REF) in turn using
// the same instantiation.
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN = 1,
          unsigned int TP_DUAL_IP = 0,
          unsigned int TP_USE_COEFF_RELOAD = 0,
          unsigned int TP_NUM_OUTPUTS = 1>
class fir_decimate_sym_ref_graph : public graph {
   public:
    port<input> in;
    port<output> out;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph(const std::vector<TT_COEFF>& taps) {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_FALSE, 1> >(
                taps);

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[0], out);

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for single input, static coeffs and dual output.
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 DUAL_IP_SINGLE,
                                 USE_COEFF_RELOAD_FALSE,
                                 2> : public graph {
   public:
    port<input> in;
    port<output> out;
    port<output> out2;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph(const std::vector<TT_COEFF>& taps) {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_FALSE, 2> >(
                taps);

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[0], out);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[1], out2);

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for dual input, static coeffs, single output
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 DUAL_IP_DUAL,
                                 USE_COEFF_RELOAD_FALSE,
                                 1> : public graph {
   public:
    port<input> in;
    port<input> in2; // dummy. Not used, but required to match uut pinout
    port<output> out;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph(const std::vector<TT_COEFF>& taps) {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_FALSE, 1> >(
                taps);

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[0], out);

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for dual input, static coeffs, dual output
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 DUAL_IP_DUAL,
                                 USE_COEFF_RELOAD_FALSE,
                                 2> : public graph {
   public:
    port<input> in;
    port<input> in2; // dummy. Not used, but required to match uut pinout
    port<output> out;
    port<output> out2;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph(const std::vector<TT_COEFF>& taps) {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_FALSE, 2> >(
                taps);

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[0], out);
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA) / TP_DECIMATE_FACTOR> >(m_firKernel.out[1], out2);

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// No specializations required for multiple kernels as the reference model ignores this parameter.
// Specialization for single input, reloadable coefficients, single output.
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN,
          unsigned int TP_DUAL_IP>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 TP_DUAL_IP,
                                 USE_COEFF_RELOAD_TRUE,
                                 1> : public graph {
   public:
    port<input> in;
    port<output> out;
    port<input> coeff;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph() {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_TRUE, 1> >();

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(
            m_firKernel.out[0], out); // /2 because of decimation by 2.
        connect<parameter>(coeff, async(m_firKernel.in[1]));

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for single input, reloadable coefficients, dual output.
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN,
          unsigned int TP_DUAL_IP>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 TP_DUAL_IP,
                                 USE_COEFF_RELOAD_TRUE,
                                 2> : public graph {
   public:
    port<input> in;
    port<output> out;
    port<output> out2;
    port<input> coeff;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph() {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_TRUE, 2> >();

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(m_firKernel.out[0], out);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(m_firKernel.out[1], out2);
        connect<parameter>(coeff, async(m_firKernel.in[1]));

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for dual Input, reloadable coefficients, single output
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 DUAL_IP_DUAL,
                                 USE_COEFF_RELOAD_TRUE,
                                 1> : public graph {
   public:
    port<input> in;
    port<input> in2; // dummy, not used, but required to match uut.
    port<output> out;
    port<input> coeff;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph() {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_TRUE, 1> >();

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(
            m_firKernel.out[0], out); // /2 because of decimation by 2.
        connect<parameter>(coeff, async(m_firKernel.in[1]));

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};

// Specialization for dual Input, reloadable coefficients, dual output
template <typename TT_DATA,
          typename TT_COEFF,
          unsigned int TP_FIR_LEN,
          unsigned int TP_DECIMATE_FACTOR,
          unsigned int TP_SHIFT,
          unsigned int TP_RND,
          unsigned int TP_INPUT_WINDOW_VSIZE,
          unsigned int TP_CASC_LEN>
class fir_decimate_sym_ref_graph<TT_DATA,
                                 TT_COEFF,
                                 TP_FIR_LEN,
                                 TP_DECIMATE_FACTOR,
                                 TP_SHIFT,
                                 TP_RND,
                                 TP_INPUT_WINDOW_VSIZE,
                                 TP_CASC_LEN,
                                 DUAL_IP_DUAL,
                                 USE_COEFF_RELOAD_TRUE,
                                 2> : public graph {
   public:
    port<input> in;
    port<input> in2; // dummy, not used, but required to match uut.
    port<output> out;
    port<output> out2;
    port<input> coeff;

    // FIR Kernel
    kernel m_firKernel;

    // Constructor
    fir_decimate_sym_ref_graph() {
        printf("=============================\n");
        printf("== FIR_DECIMATE_SYM REF Graph\n");
        printf("=============================\n");

        // Create FIR class
        m_firKernel =
            kernel::create_object<fir_decimate_sym_ref<TT_DATA, TT_COEFF, TP_FIR_LEN, TP_DECIMATE_FACTOR, TP_SHIFT,
                                                       TP_RND, TP_INPUT_WINDOW_VSIZE, USE_COEFF_RELOAD_TRUE, 2> >();

        // Make connections
        // Size of window in Bytes.
        connect<window<TP_INPUT_WINDOW_VSIZE * sizeof(TT_DATA), fnFirMargin<TP_FIR_LEN, TT_DATA>() * sizeof(TT_DATA)> >(
            in, m_firKernel.in[0]);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(m_firKernel.out[0], out);
        connect<window<(TP_INPUT_WINDOW_VSIZE / TP_DECIMATE_FACTOR) * sizeof(TT_DATA)> >(m_firKernel.out[1], out2);
        connect<parameter>(coeff, async(m_firKernel.in[1]));

        // Specify mapping constraints
        runtime<ratio>(m_firKernel) = 0.4;

        // Source files
        source(m_firKernel) = "fir_decimate_sym_ref.cpp";
    };
};
}
}
}
}
}
#endif // _DSPLIB_FIR_DECIMATE_SYM_REF_GRAPH_HPP_

/*  (c) Copyright 2020 Xilinx, Inc. All rights reserved.

    This file contains confidential and proprietary information
    of Xilinx, Inc. and is protected under U.S. and
    international copyright and other intellectual property
    laws.

    DISCLAIMER
    This disclaimer is not a license and does not grant any
    rights to the materials distributed herewith. Except as
    otherwise provided in a valid license issued to you by
    Xilinx, and to the maximum extent permitted by applicable
    law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
    WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
    AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
    BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
    INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
    (2) Xilinx shall not be liable (whether in contract or tort,
    including negligence, or under any other theory of
    liability) for any loss or damage of any kind or nature
    related to, arising under or in connection with these
    materials, including for any direct, or any indirect,
    special, incidental, or consequential loss or damage
    (including loss of data, profits, goodwill, or any type of
    loss or damage suffered as a result of any action brought
    by a third party) even if such damage or loss was
    reasonably foreseeable or Xilinx had been advised of the
    possibility of the same.

    CRITICAL APPLICATIONS
    Xilinx products are not designed or intended to be fail-
    safe, or for use in any application requiring fail-safe
    performance, such as life-support or safety devices or
    systems, Class III medical devices, nuclear facilities,
    applications related to the deployment of airbags, or any
    other applications that could lead to death, personal
    injury, or severe property or environmental damage
    (individually and collectively, "Critical
    Applications"). Customer assumes the sole risk and
    liability of any use of Xilinx products in Critical
    Applications, subject only to applicable laws and
    regulations governing limitations on product liability.

    THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
    PART OF THIS FILE AT ALL TIMES.                       */